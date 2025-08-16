using Library.Models.DTOs.Users;
using Library.Models.Entities;
using Library.Services.Database;
using Library.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUserService _userService;

        public AuthService(IUserService userService)
        {
            _userService = userService;
        }
        public async Task<UserDto?> ValidateUserAsync(string username, string password)
        {
            return await _userService.Authenticate(username, password);
        }
    }
}
