using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.UserReviews
{
    public class UserReviewInsertDto
    {
        public int Rating { get; set; }
        public string Comment { get; set; }
        public DateTime ReviewDate { get; set; } = DateTime.Now;

        public int ReviewerUserId { get; set; }
        public int ReviewedUserId { get; set; }
        public bool IsApproved { get; set; } = false;
        public bool IsDenied { get; set; } = false;
    }
}
