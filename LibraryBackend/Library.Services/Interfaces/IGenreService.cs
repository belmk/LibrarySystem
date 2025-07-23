using Library.Models.DTOs.Genres;
using Library.Models.SearchObjects;
using Library.Services.Entities;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IGenreService : ICRUDService<GenreDto, GenreSearchObject, GenreInsertDto, GenreUpdateDto>
    {
    }
}
