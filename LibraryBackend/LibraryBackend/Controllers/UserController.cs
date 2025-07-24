using Library.Models.DTOs.Books;
using Library.Models.DTOs.Users;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<UserDto, UserSearchObject, UserInsertDto, UserUpdateDto>
    {
        public UserController(ILogger<BaseController<UserDto, UserSearchObject>> logger,
                             IUserService service) : base(logger, service) { }
    }
}
