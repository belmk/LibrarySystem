using Library.Models.DTOs.Books;
using Library.Models.DTOs.Users;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using Library.Services.Services;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<UserDto, UserSearchObject, UserInsertDto, UserUpdateDto>
    {
        private readonly IUserService _userService;
        public UserController(ILogger<BaseController<UserDto, UserSearchObject>> logger,
                             IUserService service) : base(logger, service) 
        {
            _userService = service;
        }


        [Authorize(Roles = "Admin")]
        public override Task<UserDto> Insert([FromBody] UserInsertDto insert)
        {
            return base.Insert(insert);
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<ActionResult<UserDto>> Me()
        {
            var idClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(idClaim) || !int.TryParse(idClaim, out var userId))
                return Unauthorized();

            var user = await _userService.GetById(userId);
            if (user == null)
                return NotFound();

            return Ok(user);
        }
    }
}
