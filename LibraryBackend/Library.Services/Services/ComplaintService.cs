using AutoMapper;
using Library.Models.DTOs.Activities;
using Library.Models.DTOs.Complaints;
using Library.Models.DTOs.Subscriptions;
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
    public class ComplaintService : BaseCRUDService<ComplaintDto, Complaint, ComplaintSearchObject, ComplaintInsertDto, ComplaintUpdateDto>, IComplaintService
    {
        private readonly IActivityService _activityService;
        private readonly LibraryDbContext _context;

        public ComplaintService(LibraryDbContext context, IMapper mapper, IActivityService activityService) : base(context, mapper) 
        {
            _activityService = activityService;
            _context = context;
        }

        public override async Task BeforeInsert(Complaint entity, ComplaintInsertDto insert)
        {
            await base.BeforeInsert(entity, insert);

            entity.Sender = await _context.Users.FirstOrDefaultAsync(u => u.Id == entity.SenderId);
            entity.Target = await _context.Users.FirstOrDefaultAsync(u => u.Id == insert.TargetId);

            var activity = new ActivityInsertDto
            {
                UserId = entity.SenderId,
                Description =
                    $"Poslao/la žalbu protiv {entity.Target.Username} ({entity.Target.Email}): \"{entity.Reason}\"",
                ActivityDate = DateTime.UtcNow,
            };

            await _activityService.Insert(activity);
        }


        public override IQueryable<Complaint> AddFilter(IQueryable<Complaint> query, ComplaintSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery.Include(x => x.Sender).Include(x => x.Target);

            if (!String.IsNullOrEmpty(search?.Username))
            {
                filteredQuery = filteredQuery.Where(x => x.Sender.Username.Contains(search.Username));
            }

            if (!String.IsNullOrEmpty(search?.Email))
            {
                filteredQuery = filteredQuery.Where(x => x.Sender.Email.Contains(search.Email));
            }

            if (search?.ComplaintDate != null && search.ComplaintDate != DateTime.MinValue)
            {
                filteredQuery = filteredQuery.Where(x => x.ComplaintDate.Date.Equals(search.ComplaintDate.Value.Date));
            }

            if (search?.IsResolved != null)
            {
                filteredQuery = filteredQuery.Where(x => x.IsResolved ==  search.IsResolved);
            }


            return filteredQuery;
        }
    }
}
