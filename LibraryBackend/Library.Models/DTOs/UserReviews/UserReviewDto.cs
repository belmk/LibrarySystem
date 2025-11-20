using Library.Models.DTOs.Books;
using Library.Models.DTOs.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.UserReviews
{
    public class UserReviewDto
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
        public DateTime ReviewDate { get; set; }

        public UserDto ReviewerUser { get; set; }
        public UserDto ReviewedUser { get; set; }
        public bool IsApproved { get; set; }
        public bool IsDenied { get; set; }
    }
}
