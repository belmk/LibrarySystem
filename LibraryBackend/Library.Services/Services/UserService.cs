using AutoMapper;
using Library.Models.DTOs.Users;
using Library.Models.Entities;
using Library.Models.SearchObjects;
using Library.Services.Database;
using Library.Services.Entities;
using Library.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Services
{
    public class UserService : BaseCRUDService<UserDto, User, UserSearchObject, UserInsertDto, UserUpdateDto>, IUserService
    {
        public UserService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<User> AddFilter(IQueryable<User> query, UserSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery.Include(x => x.Role);


            if (!string.IsNullOrWhiteSpace(search?.FirstName))
            {
                filteredQuery = filteredQuery.Where(x => x.FirstName.Contains(search.FirstName));
            }

            if (!string.IsNullOrWhiteSpace(search?.LastName))
            {
                filteredQuery = filteredQuery.Where(x => x.FirstName.Contains(search.LastName));
            }

            if (!string.IsNullOrWhiteSpace(search?.Username))
            {
                filteredQuery = filteredQuery.Where(x => x.FirstName.Contains(search.Username));
            }

            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                filteredQuery = filteredQuery.Where(x => x.FirstName.Contains(search.Email));
            }

            if (search.IsActive.HasValue)
            {
                filteredQuery = filteredQuery.Where(x => x.IsActive == search.IsActive);
            }
            return filteredQuery;
        }

        public override async Task BeforeInsert(User entity, UserInsertDto insert)
        {
            if (insert.Password != insert.ConfirmPassword)
                throw new ArgumentException("The passwords don't match");

            if (await _context.Users.AnyAsync(u => u.Username == insert.Username))
                throw new ArgumentException("Username is already taken");

            if (await _context.Users.AnyAsync(u => u.Email == insert.Email))
                throw new ArgumentException("Email is already taken");

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);

            entity.RegistrationDate = DateTime.UtcNow;
            entity.IsActive = true;
        }

        public override async Task<UserDto> Insert(UserInsertDto dto)
        {
            var entity = _mapper.Map<User>(dto);

            await BeforeInsert(entity, dto);

            _context.Users.Add(entity);
            await _context.SaveChangesAsync();

            var fresh = await _context.Users
                .Include(r => r.Role)
                .SingleAsync(u => u.Id == entity.Id);

            return _mapper.Map<UserDto>(fresh);
        }
        public static string GenerateSalt()
        {
            byte[] saltBytes = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(saltBytes);
            }
            return Convert.ToBase64String(saltBytes);
        }

        public static string GenerateHash(string salt, string password)
        {
            var saltBytes = Convert.FromBase64String(salt);
            var passwordBytes = Encoding.UTF8.GetBytes(password);
            var combinedBytes = new byte[saltBytes.Length + passwordBytes.Length];

            Buffer.BlockCopy(saltBytes, 0, combinedBytes, 0, saltBytes.Length);
            Buffer.BlockCopy(passwordBytes, 0, combinedBytes, saltBytes.Length, passwordBytes.Length);

            using (var sha256 = SHA256.Create())
            {
                var hashBytes = sha256.ComputeHash(combinedBytes);
                return Convert.ToBase64String(hashBytes);
            }
        }

        public async Task<UserDto> Authenticate(string username, string password)
        {
            var entity = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(x => x.Username == username);

            if (entity == null)
                return null;

            var computedHash = GenerateHash(entity.PasswordSalt, password);
            if (computedHash != entity.PasswordHash)
                return null;

            return _mapper.Map<UserDto>(entity);
        }

    }
}
