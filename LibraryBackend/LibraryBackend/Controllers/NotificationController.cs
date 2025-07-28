using Library.Models.DTOs.Notifications;
using Library.Models.DTOs.Roles;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NotificationController : BaseCRUDController<NotificationDto, NotificationSearchObject, NotificationInsertDto, NotificationUpdateDto>
    {
        public NotificationController(ILogger<BaseController<NotificationDto, NotificationSearchObject>> logger,
                              INotificationService service) : base(logger, service) { }
    }
}
