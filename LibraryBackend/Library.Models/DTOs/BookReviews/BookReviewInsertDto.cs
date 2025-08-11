using Library.Models.DTOs.Books;
using Library.Models.DTOs.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.BookReviews
{
    public class BookReviewInsertDto
    {
        public int Rating { get; set; }
        public string Comment { get; set; }
        public DateTime ReviewDate { get; set; } = DateTime.UtcNow;

        public int BookId { get; set; }
        public int UserId { get; set; }
        public bool IsApproved { get; set; } = false;

    }
}
