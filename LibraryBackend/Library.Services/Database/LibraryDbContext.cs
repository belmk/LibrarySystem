using Library.Services.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Database
{
    public class LibraryDbContext : DbContext
    {
        public LibraryDbContext(DbContextOptions<LibraryDbContext> options)
        : base(options) { }

        public DbSet<Role> Roles { get; set; }
        public DbSet<Book> Books { get; set; }
        public DbSet<Author> Authors { get; set; }
        public DbSet<Genre> Genres { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Role>(entity =>
            {
                entity.HasData(
                    new Role { Id = 3, Name = "Admin" },
                    new Role { Id = 4, Name = "User"}
                    );
            });

            modelBuilder.Entity<Author>().HasData(
                new Author { Id = 1, FirstName = "George", LastName = "Orwell" },
                new Author { Id = 2, FirstName = "J.K.", LastName = "Rowling"}
            );

            modelBuilder.Entity<Genre>().HasData(
                new Genre { Id = 1, Name = "Dystopian" },
                new Genre { Id = 2, Name = "Fantasy" }
            );

            modelBuilder.Entity<Book>().HasData(
                new Book
                {
                    Id = 1,
                    AuthorId = 1,
                    Title = "1984",
                    Description = "Dystopian novel about surveillance.",
                    PageNumber = 328,
                    AvailableNumber = 5
                },
                new Book
                {
                    Id = 2,
                    AuthorId = 2,
                    Title = "Harry Potter and the Philosopher's Stone",
                    Description = "Fantasy novel about a young wizard.",
                    PageNumber = 309,
                    AvailableNumber = 8
                }


            );
            modelBuilder.Entity<Book>()
                .HasMany(b => b.Genres)
                .WithMany(g => g.Books)
                .UsingEntity(j => j.HasData(
                    new { BooksId = 1, GenresId = 1 },
                    new { BooksId = 2, GenresId = 2 }  
                ));
        }

    }
}
