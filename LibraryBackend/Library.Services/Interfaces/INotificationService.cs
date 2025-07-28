using Library.Models.DTOs.Notifications;
using Library.Models.SearchObjects;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface INotificationService : ICRUDService<NotificationDto, NotificationSearchObject, NotificationInsertDto, NotificationUpdateDto>
    {
    }
}
