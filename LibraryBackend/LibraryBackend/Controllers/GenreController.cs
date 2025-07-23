using Library.Models.DTOs.Books;
using Library.Models.DTOs.Genres;
using Library.Models.SearchObjects;
using Library.Services.Interfaces;
using LibraryBackend.Controllers.Base;
using Microsoft.AspNetCore.Mvc;

namespace LibraryBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class GenreController : BaseCRUDController<GenreDto, GenreSearchObject, GenreInsertDto, GenreUpdateDto>
    {
        public GenreController(ILogger<BaseController<GenreDto, GenreSearchObject>> logger,
                              IGenreService service) : base(logger, service) { }
    }
}
