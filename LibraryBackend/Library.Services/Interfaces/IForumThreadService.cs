using Library.Models.DTOs.ForumThreads;
using Library.Models.SearchObjects;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IForumThreadService : ICRUDService<ForumThreadDto, ForumThreadSearchObject, ForumThreadInsertDto, ForumThreadUpdateDto>
    {

    }
}
