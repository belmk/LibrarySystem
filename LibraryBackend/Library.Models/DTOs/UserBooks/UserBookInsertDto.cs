using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.UserBooks
{
    public class UserBookInsertDto
    {
        public int AuthorId { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int PageNumber { get; set; }
        public int AvailableNumber { get; set; }
        public List<int> GenreIds { get; set; } = new List<int>();
    }
}
