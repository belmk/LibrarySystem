using AutoMapper;
using Library.Models.DTOs.Authors;
using Library.Models.SearchObjects;
using Library.Services.Database;
using Library.Services.Entities;
using Library.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Services
{
    public class AuthorService : BaseCRUDService<AuthorDto, Author, AuthorSearchObject, AuthorInsertDto, AuthorUpdateDto>, IAuthorService
    {
        public AuthorService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Author> AddFilter(IQueryable<Author> query, AuthorSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery
                .Include(x => x.Books);

            if (!string.IsNullOrWhiteSpace(search?.FirstName))
            {
                filteredQuery = filteredQuery.Where(x => x.FirstName.Contains(search.FirstName));
            }

            if (!string.IsNullOrWhiteSpace(search?.LastName))
            {
                filteredQuery = filteredQuery.Where(x => x.LastName.Contains(search.LastName));
            }

            return filteredQuery;
        }
    }
}
