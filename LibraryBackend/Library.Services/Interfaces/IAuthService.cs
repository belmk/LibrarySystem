using Library.Models.DTOs.Users;
using Library.Models.Entities;
using Library.Models.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IAuthService
    {
        Task<UserDto?> ValidateUserAsync(string username, string password);
        Task<UserDto> Register(RegisterRequest request);
    }
}
