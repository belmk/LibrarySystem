using AutoMapper;
using Library.Models.DTOs.UserReviews;
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
    public class UserReviewService : BaseCRUDService<UserReviewDto, UserReview, UserReviewSearchObject, UserReviewInsertDto, UserReviewUpdateDto>, IUserReviewService
    {
        public UserReviewService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<UserReview> AddFilter(IQueryable<UserReview> query, UserReviewSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery
                .Include(x => x.ReviewedUser)
                .Include(x => x.ReviewerUser);

            if(search?.Id != null)
            {
                filteredQuery = filteredQuery.Where(x => x.Id  == search.Id);
            }

            if(search?.ReviewedUserId != null)
            {
                filteredQuery = filteredQuery.Where(x => x.ReviewedUserId == search.ReviewedUserId);
            }

            if(search?.ReviewerUserId != null)
            {
                filteredQuery = filteredQuery.Where(x => x.ReviewerUserId == search.ReviewerUserId);
            }

            return filteredQuery;
        }


    }
}
