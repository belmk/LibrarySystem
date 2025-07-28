using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.ForumComments
{
    public class ForumCommentInsertDto
    {
        public int UserId { get; set; }
        public int ForumThreadId { get; set; }
        public string Comment { get; set; }
        public DateTime CommentDate { get; set; } = DateTime.UtcNow;
    }
}
