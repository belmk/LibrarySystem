using AutoMapper;
using Library.Models.DTOs.BookReviews;
using Library.Models.Entities;
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
    public class BookReviewService : BaseCRUDService<BookReviewDto, BookReview, BookReviewSearchObject, BookReviewInsertDto, BookReviewUpdateDto>, IBookReviewService
    {
        public BookReviewService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<BookReview> AddFilter(IQueryable<BookReview> query, BookReviewSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery
                .Include(x => x.User)
                .Include(x => x.Book);

            if (!string.IsNullOrWhiteSpace(search?.Username))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Username.Contains(search.Username));
            }

            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Email.Contains(search.Email));
            }

            if (search?.ReviewDate != null && search.ReviewDate != DateTime.MinValue)
            {
                filteredQuery = filteredQuery.Where(x=>x.ReviewDate.Date.Equals(search.ReviewDate.Value.Date));
            }

            if(search?.IsApproved != null)
            {
                filteredQuery = filteredQuery.Where(x => x.IsApproved == search.IsApproved);
            }

            if (search?.IsDenied != null)
            {
                filteredQuery = filteredQuery.Where(x => x.IsDenied == search.IsDenied);
            }

            return filteredQuery;
        }
    }
}
