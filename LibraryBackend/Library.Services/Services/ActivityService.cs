using AutoMapper;
using Library.Models.DTOs.Activities;
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
    public class ActivityService : BaseCRUDService<ActivityDto, Activity, ActivitySearchObject, ActivityInsertDto, ActivityUpdateDto>, IActivityService
    {
        public ActivityService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Activity> AddFilter(IQueryable<Activity> query, ActivitySearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery
                .Include(x => x.User);

            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Email.Contains(search.Email));
            }

            if (!string.IsNullOrWhiteSpace(search?.Description))
            {
                filteredQuery = filteredQuery.Where(x => x.Description.Contains(search.Description));
            }

            if (search?.UserId != null)
            {
                filteredQuery = filteredQuery.Where(x => x.UserId ==  search.UserId);
            }

            return filteredQuery;
        }
    }
}
