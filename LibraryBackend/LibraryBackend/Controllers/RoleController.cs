using Library.Services.Database;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]/[action]")]
    public class RoleController : ControllerBase
    {
        private readonly LibraryDbContext _context;
        private readonly ILogger<RoleController> _logger;

        public RoleController(ILogger<RoleController> logger, LibraryDbContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet]
        public IActionResult GetAllRoles() { 
            var result = _context.Roles.ToList();
            return Ok(result);
        }

        [HttpPost]
        public IActionResult CreateRole(string name)
        {
            var role = new Library.Services.Entities.Role { Name = name };
            _context.Roles.Add(role);
            _context.SaveChanges(); 
            return Ok(role); 
        }
    }
}
