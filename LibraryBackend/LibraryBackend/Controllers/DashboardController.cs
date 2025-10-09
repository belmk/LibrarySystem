using Library.Models.DTOs.DashboardData;
using Library.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        [HttpGet("top-borrowed-books")]
        public async Task<ActionResult<List<BookLoanStatsDto>>> GetTopBorrowedBooks([FromQuery] int count = 5)
        {
            var data = await _dashboardService.GetTopBorrowedBooksAsync(count);
            return Ok(data);
        }

        [HttpGet("top-active-users")]
        public async Task<ActionResult<List<UserLoanStatsDto>>> GetTopActiveUsers([FromQuery] int count = 5)
        {
            var data = await _dashboardService.GetTopActiveUsersAsync(count);
            return Ok(data);
        }

        [HttpGet("top-rated-books")]
        public async Task<ActionResult<List<RatingStatsDto>>> GetTopRatedBooks([FromQuery] int count = 5)
        {
            var data = await _dashboardService.GetTopRatedBooksAsync(count);
            return Ok(data);
        }

        [HttpGet("top-rated-users")]
        public async Task<ActionResult<List<RatingStatsDto>>> GetTopRatedUsers([FromQuery] int count = 5)
        {
            var data = await _dashboardService.GetTopRatedUsersAsync(count);
            return Ok(data);
        }

        [HttpGet("borrow-stats")]
        public async Task<ActionResult<List<MonthlyRevenueDto>>> GetBorrowStats([FromQuery] int months = 6)
        {
            var data = await _dashboardService.GetBorrowsLastXMonthsAsync(months);
            return Ok(data);
        }

        [HttpGet("profit-stats")]
        public async Task<ActionResult<List<MonthlyRevenueDto>>> GetProfitStats([FromQuery] int months = 6)
        {
            var data = await _dashboardService.GetProfitLastXMonthsAsync(months);
            return Ok(data);
        }
    }
}
