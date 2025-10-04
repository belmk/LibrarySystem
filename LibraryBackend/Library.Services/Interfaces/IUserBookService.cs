using Library.Models.DTOs.UserBooks;
using Library.Models.DTOs.Users;
using Library.Models.SearchObjects;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IUserBookService : ICRUDService<UserBookDto, UserBookSearchObject, UserBookInsertDto, UserBookUpdateDto>
    {
    }
}
