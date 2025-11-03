using AutoMapper;
using Library.Models.DTOs.Activities;
using Library.Models.DTOs.ForumComments;
using Library.Models.DTOs.Notifications;
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
        private readonly INotificationService _notificationService;

        public ForumCommentService(
            LibraryDbContext context,
            IMapper mapper,
            IActivityService activityService,
            INotificationService notificationService)
            : base(context, mapper)
        {
            _activityService = activityService;
            _notificationService = notificationService;
        }

        public override async Task BeforeInsert(ForumComment entity, ForumCommentInsertDto insert)
        {
            await base.BeforeInsert(entity, insert);

            entity.ForumThread = await _context.ForumThreads
                .Include(t => t.User)
                .FirstOrDefaultAsync(t => t.Id == entity.ForumThreadId);

            var activity = new ActivityInsertDto
            {
                UserId = entity.UserId,
                Description = $"Napisao/la komentar: \"{entity.Comment}\"",
                ActivityDate = DateTime.Now,
            };

            await _activityService.Insert(activity);

            if (entity.ForumThread?.UserId != null && entity.ForumThread.UserId != entity.UserId)
            {
                var notification = new NotificationInsertDto
                {
                    UserId = entity.ForumThread.UserId,
                    Title = "Novi komentar",
                    Message = $"Primili ste novi komentar od korisnika {entity.User?.Username ?? "nepoznat"} na vašoj objavi \"{entity.ForumThread.Title}\"",
                    ReceivedDate = DateTime.Now,
                };

                await _notificationService.Insert(notification);
            }
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
