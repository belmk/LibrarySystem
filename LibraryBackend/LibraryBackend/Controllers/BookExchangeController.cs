using Library.Models.DTOs.Activities;
using Library.Models.DTOs.BookExchanges;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookExchangeController : BaseCRUDController<BookExchangeDto, BookExchangeSearchObject, BookExchangeInsertDto, BookExchangeUpdateDto>
    {
        public BookExchangeController(ILogger<BaseController<BookExchangeDto, BookExchangeSearchObject>> logger,
                                 IBookExchangeService service) : base(logger, service) { }
    }
}
