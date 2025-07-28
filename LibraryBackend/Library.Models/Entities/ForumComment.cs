using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.Entities
{
    public class ForumComment
    {
        public int Id { get; set; }
        public int ForumThreadId { get; set; }
        public ForumThread ForumThread { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public string Comment { get; set; }
        public DateTime CommentDate { get; set; }
    }
}
