using Library.Models.DTOs.Authors;
using Library.Models.DTOs.BookReviews;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookReviewController : BaseCRUDController<BookReviewDto, BookReviewSearchObject, BookReviewInsertDto, BookReviewUpdateDto>
    {
        public BookReviewController(ILogger<BaseController<BookReviewDto, BookReviewSearchObject>> logger,
                                 IBookReviewService service) : base(logger, service) { }
    }
}
