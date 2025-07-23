using Library.Models.DTOs.Authors;
using Library.Models.SearchObjects;
using Library.Services.BaseServices;
using Library.Services.Entities;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IAuthorService : ICRUDService<AuthorDto, AuthorSearchObject, AuthorInsertDto, AuthorUpdateDto>
    {
    }
}
