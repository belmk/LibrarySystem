using Library.Models.DTOs.BookReviews;
using Library.Models.DTOs.UserReviews;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserReviewController : BaseCRUDController<UserReviewDto, UserReviewSearchObject, UserReviewInsertDto, UserReviewUpdateDto>
    {
        public UserReviewController(ILogger<BaseController<UserReviewDto, UserReviewSearchObject>> logger,
                                  IUserReviewService service) : base(logger, service) { }
    }
}
