using AutoMapper;
using Library.Models.DTOs.Activities;
using Library.Models.DTOs.ForumComments;
using Library.Models.DTOs.ForumThreads;
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
    public class ForumThreadService : BaseCRUDService<ForumThreadDto, ForumThread, ForumThreadSearchObject, ForumThreadInsertDto, ForumThreadUpdateDto>, IForumThreadService
    {
        private readonly IActivityService _activityService;

        public ForumThreadService(LibraryDbContext context, IMapper mapper, IActivityService activityService) : base(context, mapper) 
        { 
            _activityService = activityService;
        }

        public override async Task BeforeInsert(ForumThread entity, ForumThreadInsertDto insert)
        {
            await base.BeforeInsert(entity, insert);

            var activity = new ActivityInsertDto
            {
                UserId = entity.UserId,
                Description = $"Pokrenuo/la forum za knjigu \"{entity.Book.Title}\" pod nazivom \"{entity.Title}\"",
                ActivityDate = DateTime.UtcNow,
            };

            await _activityService.Insert(activity);
        }

        public override IQueryable<ForumThread> AddFilter(IQueryable<ForumThread> query, ForumThreadSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery
                .Include(x => x.Book)
                .Include(x => x.User);

            if (!string.IsNullOrWhiteSpace(search?.ForumTitle))
            {
                filteredQuery = filteredQuery.Where(x => x.Title.Contains(search.ForumTitle));
            }

            if (!string.IsNullOrWhiteSpace(search?.BookTitle))
            {
                filteredQuery = filteredQuery.Where(x => x.Book.Title.Contains(search.BookTitle));
            }

            if (!string.IsNullOrWhiteSpace(search?.Username))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Username.Contains(search.Username));
            }

            filteredQuery = filteredQuery.OrderByDescending(x => x.ThreadDate);

            return filteredQuery;
        }
    }
}
