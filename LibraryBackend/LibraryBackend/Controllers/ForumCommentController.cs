using Library.Models.DTOs.Activities;
using Library.Models.DTOs.ForumComments;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ForumCommentController : BaseCRUDController<ForumCommentDto, ForumCommentSearchObject,ForumCommentInsertDto,ForumCommentUpdateDto>
    {
        public ForumCommentController(ILogger<BaseController<ForumCommentDto, ForumCommentSearchObject>> logger,
                                 IForumCommentService service) : base(logger, service) { }
    }
}
