using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.ForumThreads
{
    public class ForumThreadInsertDto
    {
        public int UserId { get; set; }
        public int BookId { get; set; }
        public string Title { get; set; }
        public DateTime ThreadDate { get; set; } = DateTime.UtcNow;
    }
}
