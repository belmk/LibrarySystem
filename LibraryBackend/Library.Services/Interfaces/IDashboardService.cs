using Library.Models.DTOs.DashboardData;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IDashboardService
    {
        Task<List<BookLoanStatsDto>> GetTopBorrowedBooksAsync(int count);
        Task<List<UserLoanStatsDto>> GetTopActiveUsersAsync(int count);
        Task<List<RatingStatsDto>> GetTopRatedBooksAsync(int count);
        Task<List<RatingStatsDto>> GetTopRatedUsersAsync(int count);

        Task<List<MonthlyRevenueDto>> GetBorrowsLastXMonthsAsync(int months);
        Task<List<MonthlyRevenueDto>> GetProfitLastXMonthsAsync(int months);
    }
}
