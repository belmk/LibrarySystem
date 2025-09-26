using Library.Models.DTOs.BookLoans;
using Library.Models.DTOs.Users;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookLoanController : BaseCRUDController<BookLoanDto, BookLoanSearchObject, BookLoanInsertDto, BookLoanUpdateDto>
    {
        private readonly IBookLoanService _bookLoanService;
        public BookLoanController(ILogger<BaseController<BookLoanDto, BookLoanSearchObject>> logger,
                             IBookLoanService service) : base(logger, service)
        {
            _bookLoanService = service;
        }
    }
}
