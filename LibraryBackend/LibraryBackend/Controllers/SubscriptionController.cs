using Library.Models.DTOs.Genres;
using Library.Models.DTOs.Subscriptions;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SubscriptionController : BaseCRUDController<SubscriptionDto, SubscriptionSearchObject, SubscriptionInsertDto, SubscriptionUpdateDto>
    {
        public SubscriptionController(ILogger<BaseController<SubscriptionDto, SubscriptionSearchObject>> logger,
                              ISubscriptionService service) : base(logger, service) { }

    }
}
