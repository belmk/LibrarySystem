using AutoMapper;
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
    public class SubscriptionService : BaseCRUDService<SubscriptionDto, Subscription, SubscriptionSearchObject, SubscriptionInsertDto, SubscriptionUpdateDto>, ISubscriptionService
    {
        public SubscriptionService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Subscription> AddFilter(IQueryable<Subscription> query, SubscriptionSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery
                .Include(x => x.User);

            if (search.UserId.HasValue)
            {
                filteredQuery = filteredQuery.Where(x => x.UserId.Equals(search.UserId));
            }

            return filteredQuery;
        }

    }
}
