using Library.Models.DTOs.Books;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookController : BaseCRUDController<BookDto, BookSearchObject, BookInsertDto, BookUpdateDto>
    {
        public BookController(ILogger<BaseController<BookDto, BookSearchObject>> logger,
                              IBookService service) : base(logger, service) { }
    }
}
