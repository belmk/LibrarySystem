using Library.Models.DTOs.Activities;
using Library.Models.DTOs.UserBooks;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserBookController : BaseCRUDController<UserBookDto, UserBookSearchObject, UserBookInsertDto, UserBookUpdateDto>
    {
        public UserBookController(ILogger<BaseController<UserBookDto, UserBookSearchObject>> logger,
                                 IUserBookService service) : base(logger, service) { }
    }
}
