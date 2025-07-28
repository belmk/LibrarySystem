using Library.Models.DTOs.Books;
using Library.Models.DTOs.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.BookReviews
{
    public class BookReviewDto
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
        public DateTime ReviewDate { get; set; }

        public BookDto Book { get; set; }
        public UserDto User { get; set; }
    }
}
