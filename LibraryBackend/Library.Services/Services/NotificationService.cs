using AutoMapper;
using Library.Models.DTOs.Notifications;
using Library.Models.Entities;
using Library.Models.SearchObjects;
using Library.Services.Database;
using Library.Services.Entities;
using Library.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Services
{
    public class NotificationService : BaseCRUDService<NotificationDto, Notification, NotificationSearchObject, NotificationInsertDto, NotificationUpdateDto>, INotificationService
    {
        public NotificationService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Notification> AddFilter(IQueryable<Notification> query, NotificationSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Title))
            {
                filteredQuery = filteredQuery.Where(x => x.Title.Contains(search.Title));
            }

            if (!string.IsNullOrWhiteSpace(search?.Message))
            {
                filteredQuery = filteredQuery.Where(x => x.Message.Contains(search.Message));
            }

            return filteredQuery;
        }
    }
}
