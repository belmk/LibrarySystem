using Library.Models.Entities;
using Library.Services.Entities;
using Library.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Database
{
    public class DatabaseSeeder
    {
        private readonly LibraryDbContext _context;

        public DatabaseSeeder(LibraryDbContext context)
        {
            _context = context;
        }

        public void Seed()
        {
            AddRoles();
            AddAuthors();
            AddGenres();
            AddBooks();
            AddUsers();
        }

        private void AddRoles()
        {
            if (!_context.Roles.Any())
            {
                _context.Roles.AddRange(
                    new Role { Name = "Admin" },
                    new Role { Name = "User" }
                );
                _context.SaveChanges();
            }
        }

        private void AddAuthors()
        {
            if (!_context.Authors.Any())
            {
                _context.Authors.AddRange(
                    new Author { FirstName = "George", LastName = "Orwell" },
                    new Author { FirstName = "J.K.", LastName = "Rowling" }
                );
                _context.SaveChanges();
            }
        }

        private void AddGenres()
        {
            if (!_context.Genres.Any())
            {
                _context.Genres.AddRange(
                    new Genre { Name = "Dystopian" },
                    new Genre { Name = "Fantasy" }
                );
                _context.SaveChanges();
            }
        }

        private void AddBooks()
        {
            if (!_context.Books.Any())
            {
                var orwell = _context.Authors.First(a => a.LastName == "Orwell");
                var rowling = _context.Authors.First(a => a.LastName == "Rowling");

                var dystopian = _context.Genres.First(g => g.Name == "Dystopian");
                var fantasy = _context.Genres.First(g => g.Name == "Fantasy");

                var book1 = new Book
                {
                    Title = "1984",
                    Author = orwell,
                    Description = "Dystopian novel about surveillance.",
                    PageNumber = 328,
                    AvailableNumber = 5,
                };
                book1.Genres.Add(dystopian);

                var book2 = new Book
                {
                    Title = "Harry Potter and the Philosopher's Stone",
                    Author = rowling,
                    Description = "Fantasy novel about a young wizard.",
                    PageNumber = 309,
                    AvailableNumber = 8,
                };
                book2.Genres.Add(fantasy);

                _context.Books.AddRange(book1, book2);
                _context.SaveChanges();
            }
        }


        private void AddUsers()
        {
            if (!_context.Users.Any())
            {
                var adminRole = _context.Roles.FirstOrDefault(r => r.Name == "Admin");
                var userRole = _context.Roles.FirstOrDefault(r => r.Name == "User");

                if (adminRole == null || userRole == null)
                {
                    throw new InvalidOperationException("Roles must exist before creating users.");
                }

                var adminSalt = UserService.GenerateSalt();
                var admin = new User
                {
                    FirstName = "Admin",
                    LastName = "Adminović",
                    Username = "admin",
                    Email = "admin@example.com",
                    RoleId = adminRole.Id,
                    PasswordSalt = adminSalt,
                    PasswordHash = UserService.GenerateHash(adminSalt, "admin"),
                    RegistrationDate = DateTime.UtcNow,
                    IsActive = true,
                    WarningNumber = 0
                };

                var userSalt = UserService.GenerateSalt();
                var user = new User
                {
                    FirstName = "Korisnik",
                    LastName = "Koristić",
                    Username = "user",
                    Email = "user@example.com",
                    RoleId = userRole.Id,
                    PasswordSalt = userSalt,
                    PasswordHash = UserService.GenerateHash(userSalt, "user"),
                    RegistrationDate = DateTime.UtcNow,
                    IsActive = true,
                    WarningNumber = 0
                };

                _context.Users.AddRange(admin, user);
                _context.SaveChanges();
            }
        }

    }
}
