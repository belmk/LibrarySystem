using Library.Models.DTOs.ForumThreads;
using Library.Models.DTOs.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.ForumComments
{
    public class ForumCommentDto
    {
        public int Id { get; set; }
        public UserDto User { get; set; }
        public ForumThreadDto ForumThread { get; set; }
        public string Comment { get; set; }
        public DateTime CommentDate { get; set; }
    }
}
