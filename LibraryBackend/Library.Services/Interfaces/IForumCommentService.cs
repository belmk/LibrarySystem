using Library.Models.DTOs.ForumComments;
using Library.Models.SearchObjects;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IForumCommentService : ICRUDService<ForumCommentDto, ForumCommentSearchObject, ForumCommentInsertDto, ForumCommentUpdateDto>
    {
    }
}
