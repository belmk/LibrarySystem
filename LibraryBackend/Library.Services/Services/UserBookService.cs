using AutoMapper;
using Library.Models.DTOs.UserBooks;
using Library.Models.Entities;
using Library.Models.SearchObjects;
using Library.Services.Database;
using Library.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Services
{
    public class UserBookService : BaseCRUDService<UserBookDto, UserBook, UserBookSearchObject, UserBookInsertDto, UserBookUpdateDto>, IUserBookService
    {
        public UserBookService(LibraryDbContext context, IMapper mapper) : base(context, mapper){ }

        public override IQueryable<UserBook> AddFilter(IQueryable<UserBook> query, UserBookSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery.Include(x => x.User);

            if (!string.IsNullOrWhiteSpace(search?.Username))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Username.ToLower().Contains(search.Username.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Email.ToLower().Contains(search.Email.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search?.Title))
            {
                filteredQuery = filteredQuery.Where(x => x.Title.ToLower().Contains(search.Title.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search?.AuthorName))
            {
                var authorSearch = search.AuthorName.Trim().ToLower();

                filteredQuery = filteredQuery.Where(x =>
                    x.Author.FirstName.ToLower().Contains(authorSearch) ||
                    x.Author.LastName.ToLower().Contains(authorSearch) ||
                    (x.Author.FirstName + " " + x.Author.LastName).ToLower().Contains(authorSearch)
                );
            }

            return filteredQuery;
        }
    }
}
