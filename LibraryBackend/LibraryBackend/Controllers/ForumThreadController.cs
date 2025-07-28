using Library.Models.DTOs.Authors;
using Library.Models.DTOs.ForumThreads;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ForumThreadController : BaseCRUDController<ForumThreadDto, ForumThreadSearchObject, ForumThreadInsertDto, ForumThreadUpdateDto>
    {
        public ForumThreadController(ILogger<BaseController<ForumThreadDto, ForumThreadSearchObject>> logger,
                                 IForumThreadService service) : base(logger, service) { }
    }
}
