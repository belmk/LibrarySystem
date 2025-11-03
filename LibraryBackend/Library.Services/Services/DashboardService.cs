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

            var rawData = await _context.BookLoans
                .Where(b => b.LoanDate >= fromDate && b.LoanDate != null)
                .GroupBy(b => new { b.LoanDate.Value.Year, b.LoanDate.Value.Month })
                .Select(g => new
                {
                    g.Key.Year,
                    g.Key.Month,
                    BorrowCount = g.Count()
                })
                .ToListAsync();

            var projected = rawData
                .Select(g => new MonthlyRevenueDto
                {
                    Month = $"{g.Month:D2}/{g.Year}",
                    Count = g.BorrowCount
                })
                .OrderBy(g => g.Month)
                .ToList();

            return projected;
        }





        public async Task<List<MonthlyRevenueDto>> GetProfitLastXMonthsAsync(int months)
        {
            var now = DateTime.Now;
            var fromDate = new DateTime(now.Year, now.Month, 1).AddMonths(-months + 1); 

            var rawData = await _context.Subscriptions
                .Where(s => s.StartDate >= fromDate)
                .GroupBy(s => new { s.StartDate.Year, s.StartDate.Month })
                .Select(g => new
                {
                    g.Key.Year,
                    g.Key.Month,
                    TotalRevenue = g.Sum(s => s.Price)
                })
                .ToListAsync();

            var allMonths = Enumerable.Range(0, months)
                .Select(i => fromDate.AddMonths(i))
                .ToList();

            var projected = allMonths
                .Select(date =>
                {
                    var match = rawData.FirstOrDefault(d => d.Year == date.Year && d.Month == date.Month);
                    return new MonthlyRevenueDto
                    {
                        Month = $"{date.Month:D2}/{date.Year}", 
                        Count = (int?)match?.TotalRevenue ?? 0
                    };
                })
                .ToList();

            return projected;
        }
    }
}
