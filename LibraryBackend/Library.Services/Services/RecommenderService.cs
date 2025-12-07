using AutoMapper;
using Library.Models.DTOs.Books;
using Library.Models.Entities;
using Library.Services.Database;
using Library.Services.Entities;
using Library.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Services
{
    public class RecommenderService : IRecommenderService
    {
        private readonly LibraryDbContext _db;
        private readonly IMapper _mapper;

        private static readonly object _sync = new();
        private static MLContext _ml;
        private static Dictionary<int, float[]> _bookVectors;

        public RecommenderService(LibraryDbContext db, IMapper mapper)
        {
            _db = db;
            _mapper = mapper;
            BuildModelIfNeeded();
        }

        public async Task<IReadOnlyList<BookDto>> RecommendAsync(
            int userId,
            int take = 10,
            CancellationToken ct = default)
        {
            if (_bookVectors == null || _bookVectors.Count == 0)
                return await ColdStartAsync(take, ct);

            if (userId <= 0)
                return await ColdStartAsync(take, ct);

            var weights = new Dictionary<int, float>();

            var reviews = await _db.Set<BookReview>()
                .Where(r => r.UserId == userId && r.IsApproved && !r.IsDenied)
                .Select(r => new { r.BookId, r.Rating })
                .ToListAsync(ct);

            foreach (var r in reviews)
            {
                if (_bookVectors.ContainsKey(r.BookId))
                {
                    float w = Math.Clamp(r.Rating, 1, 5) / 5f;
                    weights[r.BookId] = weights.GetValueOrDefault(r.BookId) + 2f * w;
                }
            }

            var loans = await _db.Set<BookLoan>()
                .Where(l => l.UserId == userId)
                .Select(l => new { l.BookId })
                .ToListAsync(ct);

            foreach (var l in loans)
            {
                if (_bookVectors.ContainsKey(l.BookId))
                {
                    weights[l.BookId] = weights.GetValueOrDefault(l.BookId) + 1.5f;
                }
            }

            if (weights.Count == 0)
                return await ColdStartAsync(take, ct);

            var profile = WeightedAverage(weights);
            var exclude = weights.Keys.ToHashSet();

            var candidateIds = await _db.Set<Book>()
                .Where(b => b.AvailableNumber > 0)
                .Select(b => b.Id)
                .ToListAsync(ct);

            var scored = new List<(int BookId, float Score)>(candidateIds.Count);

            foreach (var id in candidateIds)
            {
                if (exclude.Contains(id)) continue;
                if (!_bookVectors.TryGetValue(id, out var vec)) continue;

                scored.Add((id, Cosine(profile, vec)));
            }

            var topIds = scored
                .OrderByDescending(s => s.Score)
                .Take(take)
                .Select(s => s.BookId)
                .ToList();

            if (topIds.Count == 0)
                return await ColdStartAsync(take, ct);

            var books = await _db.Set<Book>()
                .Where(b => topIds.Contains(b.Id))
                .Include(b => b.Author)
                .Include(b => b.Genres)
                .ToListAsync(ct);

            // Map to DTOs before returning
            return topIds.Select(id => _mapper.Map<BookDto>(books.First(b => b.Id == id))).ToList();
        }

        private void BuildModelIfNeeded()
        {
            if (_bookVectors != null) return;

            lock (_sync)
            {
                if (_bookVectors != null) return;

                _ml = new MLContext(seed: 1);

                var rows = LoadBookRows();
                if (rows.Count == 0)
                {
                    _bookVectors = new();
                    return;
                }

                var data = _ml.Data.LoadFromEnumerable(rows);

                var pipeline =
                    _ml.Transforms.Text.FeaturizeText("TitleFeats", nameof(BookRow.Title))
                    .Append(_ml.Transforms.Text.FeaturizeText("AuthorFeats", nameof(BookRow.Authors)))
                    .Append(_ml.Transforms.Text.FeaturizeText("GenreFeats", nameof(BookRow.Genres)))
                    .Append(_ml.Transforms.Text.FeaturizeText("DescFeats", nameof(BookRow.Description)))
                    .Append(_ml.Transforms.Concatenate("Features", "TitleFeats", "AuthorFeats", "GenreFeats", "DescFeats"))
                    .Append(_ml.Transforms.NormalizeLpNorm("Features"));

                var model = pipeline.Fit(data);
                var transformed = model.Transform(data);

                var vectors = _ml.Data.CreateEnumerable<VectorRow>(transformed, reuseRowObject: false);
                _bookVectors = vectors.ToDictionary(v => v.BookId, v => v.Features);
            }
        }

        private List<BookRow> LoadBookRows()
            => _db.Set<Book>()
                .Include(b => b.Author)
                .Include(b => b.Genres)
                .AsNoTracking()
                .Select(b => new BookRow
                {
                    BookId = b.Id,
                    Title = b.Title ?? "",
                    Authors = b.Author != null ? $"{b.Author.FirstName} {b.Author.LastName}" : "",
                    Genres = string.Join(",", b.Genres.Select(g => g.Name)),
                    Description = b.Description ?? ""
                })
                .ToList();

        private async Task<List<BookDto>> ColdStartAsync(int take, CancellationToken ct)
        {
            var topRated = await _db.Set<BookReview>()
                .Where(r => r.IsApproved && !r.IsDenied)
                .GroupBy(r => r.BookId)
                .Select(g => new { BookId = g.Key, AvgRating = g.Average(x => x.Rating), Count = g.Count() })
                .OrderByDescending(x => x.AvgRating)
                .ThenByDescending(x => x.Count)
                .Take(take * 2)
                .ToListAsync(ct);

            var ids = topRated.Select(x => x.BookId).ToList();

            var books = await _db.Set<Book>()
                .Where(b => ids.Contains(b.Id))
                .Include(b => b.Author)
                .Include(b => b.Genres)
                .Take(take)
                .ToListAsync(ct);

            if (books.Count > 0)
                return books.Select(b => _mapper.Map<BookDto>(b)).ToList();

            var mostBorrowed = await _db.Set<BookLoan>()
                .GroupBy(l => l.BookId)
                .Select(g => new { BookId = g.Key, Cnt = g.Count() })
                .OrderByDescending(x => x.Cnt)
                .Take(take)
                .ToListAsync(ct);

            ids = mostBorrowed.Select(x => x.BookId).ToList();

            books = await _db.Set<Book>()
                .Where(b => ids.Contains(b.Id))
                .Include(b => b.Author)
                .Include(b => b.Genres)
                .ToListAsync(ct);

            if (books.Count > 0)
                return books.Select(b => _mapper.Map<BookDto>(b)).ToList();

            var fallbackBooks = await _db.Set<Book>()
                .Include(b => b.Author)
                .Include(b => b.Genres)
                .OrderBy(b => b.Title)
                .Take(take)
                .ToListAsync(ct);

            return fallbackBooks.Select(b => _mapper.Map<BookDto>(b)).ToList();
        }

        private static float[] WeightedAverage(Dictionary<int, float> weights)
        {
            var firstId = weights.Keys.First();
            if (!_bookVectors.TryGetValue(firstId, out var first))
                return Array.Empty<float>();

            var sum = new float[first.Length];
            float wsum = 0;

            foreach (var (id, w) in weights)
            {
                if (!_bookVectors.TryGetValue(id, out var vec)) continue;

                for (int i = 0; i < vec.Length; i++)
                    sum[i] += vec[i] * w;

                wsum += w;
            }

            if (wsum > 1e-6f)
                for (int i = 0; i < sum.Length; i++)
                    sum[i] /= wsum;

            return sum;
        }

        private static float Cosine(float[] a, float[] b)
        {
            if (a == null || b == null || a.Length == 0 || b.Length == 0)
                return 0;

            float dot = 0, ma = 0, mb = 0;

            int n = Math.Min(a.Length, b.Length);
            for (int i = 0; i < n; i++)
            {
                dot += a[i] * b[i];
                ma += a[i] * a[i];
                mb += b[i] * b[i];
            }

            const float eps = 1e-6f;
            return dot / (MathF.Sqrt(ma) * MathF.Sqrt(mb) + eps);
        }

        private class BookRow
        {
            public int BookId { get; set; }
            public string Title { get; set; }
            public string Authors { get; set; }
            public string Genres { get; set; }
            public string Description { get; set; }
        }

        private class VectorRow
        {
            public int BookId { get; set; }

            [VectorType]
            public float[] Features { get; set; }
        }
    }
}
