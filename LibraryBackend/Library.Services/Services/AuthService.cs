using AutoMapper;
using Library.Models.DTOs.Users;
using Library.Models.Entities;
using Library.Models.Requests;
using Library.Models.SearchObjects;
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
        private readonly IRoleService _roleService;
        private readonly IMapper _mapper;

        public AuthService(IUserService userService, IMapper mapper, IRoleService roleService)
        {
            _userService = userService;
            _mapper = mapper;
            _roleService = roleService;
        }

        public async Task<UserDto> Register(RegisterRequest request)
        {
            if (request.RoleId == 0)
            {
                var userRole = await _roleService.Get(new RoleSearchObject { Name = "User" });
                var role = userRole.Result.FirstOrDefault();
                if (role == null)
                    throw new Exception("Default role 'User' not found.");

                request.RoleId = role.Id;
            }
            var insertDto = _mapper.Map<UserInsertDto>(request);

           var user = await _userService.Insert(insertDto);

           return user;
        }

        public async Task<UserDto?> ValidateUserAsync(string username, string password)
        {
            return await _userService.Authenticate(username, password);
        }
    }
}
