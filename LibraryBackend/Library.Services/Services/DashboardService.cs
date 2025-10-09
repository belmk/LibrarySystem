using Library.Models.DTOs.DashboardData;
using Library.Services.Database;
using Library.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Library.Services.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly LibraryDbContext _context;

        public DashboardService(LibraryDbContext context)
        {
            _context = context;
        }

        public async Task<List<BookLoanStatsDto>> GetTopBorrowedBooksAsync(int count)
        {
            return await _context.BookLoans
                .Where(bl => bl.LoanDate != null)
                .GroupBy(bl => bl.Book.Title)
                .Select(g => new BookLoanStatsDto
                {
                    Title = g.Key,
                    LoanCount = g.Count()
                })
                .OrderByDescending(dto => dto.LoanCount)
                .Take(count)
                .ToListAsync();
        }

        public async Task<List<UserLoanStatsDto>> GetTopActiveUsersAsync(int count)
        {
            return await _context.BookLoans
                .Where(bl => bl.LoanDate != null)
                .GroupBy(bl => bl.User.Username)
                .Select(g => new UserLoanStatsDto
                {
                    Username = g.Key,
                    LoanCount = g.Count()
                })
                .OrderByDescending(dto => dto.LoanCount)
                .Take(count)
                .ToListAsync();
        }

        public async Task<List<RatingStatsDto>> GetTopRatedBooksAsync(int count)
        {
            return await _context.BookReviews
                .Where(r => r.IsApproved && !r.IsDenied)
                .GroupBy(r => r.Book.Title)
                .Select(g => new RatingStatsDto
                {
                    Name = g.Key,
                    AvgRating = g.Average(r => r.Rating),
                    TotalRatings = g.Count()
                })
                .OrderByDescending(dto => dto.AvgRating)
                .ThenByDescending(dto => dto.TotalRatings)
                .Take(count)
                .ToListAsync();
        }

        public async Task<List<RatingStatsDto>> GetTopRatedUsersAsync(int count)
        {
            return await _context.BookReviews
                .Where(r => r.IsApproved && !r.IsDenied)
                .GroupBy(r => r.User.Username)
                .Select(g => new RatingStatsDto
                {
                    Name = g.Key,
                    AvgRating = g.Average(r => r.Rating),
                    TotalRatings = g.Count()
                })
                .OrderByDescending(dto => dto.AvgRating)
                .ThenByDescending(dto => dto.TotalRatings)
                .Take(count)
                .ToListAsync();
        }

        public async Task<List<MonthlyRevenueDto>> GetBorrowsLastXMonthsAsync(int months)
        {
            var fromDate = DateTime.Now.AddMonths(-months + 1);

            return await _context.BookLoans
                .Where(bl => bl.LoanDate != null && bl.LoanDate >= fromDate)
                .GroupBy(bl => new { bl.LoanDate.Value.Year, bl.LoanDate.Value.Month })
                .Select(g => new MonthlyRevenueDto
                {
                    Month = $"{g.Key.Month:D2}/{g.Key.Year}",
                    Count = g.Count()
                })
                .OrderBy(g => g.Month)
                .ToListAsync();
        }

        public async Task<List<MonthlyRevenueDto>> GetProfitLastXMonthsAsync(int months)
        {
            var fromDate = DateTime.Now.AddMonths(-months + 1);

            return await _context.Subscriptions
                .Where(s => s.StartDate >= fromDate && !s.IsCancelled)
                .GroupBy(s => new { s.StartDate.Year, s.StartDate.Month })
                .Select(g => new MonthlyRevenueDto
                {
                    Month = $"{g.Key.Month:D2}/{g.Key.Year}",
                    Count = (int)g.Sum(s => s.Price) // You can use `decimal` in DTO if needed
                })
                .OrderBy(g => g.Month)
                .ToListAsync();
        }
    }
}
