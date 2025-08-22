using Library.Models.DTOs.Activities;
using Library.Models.DTOs.Authors;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ActivityController : BaseCRUDController<ActivityDto, ActivitySearchObject, ActivityInsertDto, ActivityUpdateDto>
    {
        public ActivityController(ILogger<BaseController<ActivityDto, ActivitySearchObject>> logger,
                                 IActivityService service) : base(logger, service) { }
    }
}
