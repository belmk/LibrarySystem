using AutoMapper;
using Library.Models.DTOs.Activities;
using Library.Models.DTOs.ForumComments;
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
    public class ForumCommentService : BaseCRUDService<ForumCommentDto, ForumComment, ForumCommentSearchObject, ForumCommentInsertDto, ForumCommentUpdateDto>, IForumCommentService
    {
        private readonly IActivityService _activityService;

        public ForumCommentService(
            LibraryDbContext context,
            IMapper mapper,
            IActivityService activityService)
            : base(context, mapper)
        {
            _activityService = activityService;
        }

        public override async Task BeforeInsert(ForumComment entity, ForumCommentInsertDto insert)
        {
            await base.BeforeInsert(entity, insert);

            var activity = new ActivityInsertDto
            {
                UserId = entity.UserId,
                Description = $"Napisao/la komentar: \"{entity.Comment}\"",
                ActivityDate = DateTime.UtcNow,
            };

            await _activityService.Insert(activity);
        }
        public override IQueryable<ForumComment> AddFilter(IQueryable<ForumComment> query, ForumCommentSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery
                .Include(x => x.User);

            if (!string.IsNullOrWhiteSpace(search?.Username))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Username.Contains(search.Username));
            }

            if (!string.IsNullOrWhiteSpace(search?.Comment))
            {
                filteredQuery = filteredQuery.Where(x => x.Comment.Contains(search.Comment));
            }

            if (search?.ForumThreadId != null)
            {
                filteredQuery = filteredQuery.Where(x => x.ForumThreadId ==  search.ForumThreadId);
            }

            return filteredQuery;
        }
    }
}
