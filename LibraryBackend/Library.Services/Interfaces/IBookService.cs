using Library.Models.DTOs.Books;
using Library.Models.SearchObjects;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IBookService : ICRUDService<BookDto, BookSearchObject, BookInsertDto, BookUpdateDto>
    {
    }
}
