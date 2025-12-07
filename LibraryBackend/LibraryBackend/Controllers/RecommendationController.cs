using Library.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class RecommendationController : Controller
    {
        [HttpGet("recommendations")]
        public async Task<IActionResult> GetRecommendations(
            [FromServices] IRecommenderService recommender,
            [FromQuery] int take = 10,
            CancellationToken ct = default)
        {
            var claim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (!int.TryParse(claim, out int userId))
                return Unauthorized();

            var recommendations = await recommender.RecommendAsync(userId, take, ct);
            return Ok(recommendations);
        }
    }
}
