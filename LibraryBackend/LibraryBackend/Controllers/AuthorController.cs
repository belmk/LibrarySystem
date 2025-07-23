using Library.Models.DTOs.Authors;
using Library.Models.DTOs.Genres;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AuthorController : BaseCRUDController<AuthorDto, AuthorSearchObject, AuthorInsertDto, AuthorUpdateDto>
    {
        public AuthorController(ILogger<BaseController<AuthorDto, AuthorSearchObject>> logger,
                                 IAuthorService service) : base(logger, service) { }
    }
}
