using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.Entities
{
    public class UserReview
    {
        public int Id { get; set; }
        public int ReviewedUserId { get; set; }
        public User ReviewedUser { get; set; }
        public int ReviewerUserId { get; set; }
        public User ReviewerUser { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
        public DateTime ReviewDate { get; set; }
        public bool IsApproved { get; set; }
        public bool IsDenied { get; set; }
    }
}
