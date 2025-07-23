using Library.Models.DTOs.Genres;
using Library.Models.DTOs.Roles;
using Library.Models.SearchObjects;
using Library.Services.Database;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RoleController : BaseCRUDController<RoleDto, RoleSearchObject, RoleInsertDto, RoleUpdateDto>
    {
        public RoleController(ILogger<BaseController<RoleDto, RoleSearchObject>> logger,
                              IRoleService service) : base(logger, service) { }
    }
}
