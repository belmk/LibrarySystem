using Library.Models.DTOs.Authors;
using Library.Models.DTOs.Complaints;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ComplaintController : BaseCRUDController<ComplaintDto, ComplaintSearchObject, ComplaintInsertDto, ComplaintUpdateDto>
    {
        public ComplaintController(ILogger<BaseController<ComplaintDto, ComplaintSearchObject>> logger,
                                 IComplaintService service) : base(logger, service) { }
    }
}
