using AutoMapper;
using Library.Models.DTOs.Books;
using Library.Models.SearchObjects;
using Library.Services.Database;
using Library.Services.Entities;
using Library.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Services
{
    public class BookService : BaseCRUDService<BookDto, Book, BookSearchObject, BookInsertDto, BookUpdateDto>, IBookService
    {
        public BookService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Book> AddFilter(IQueryable<Book> query, BookSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery.Include(x => x.Genres);

            if (!string.IsNullOrWhiteSpace(search?.Title))
            {
                filteredQuery = filteredQuery.Where(x => x.Title.Contains(search.Title));
            }

            return filteredQuery;
        }
    }
}
