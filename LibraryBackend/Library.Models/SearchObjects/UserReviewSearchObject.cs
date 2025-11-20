using Library.Models.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.SearchObjects
{
    public class UserReviewSearchObject : BaseSearchObject
    {
        public int? ReviewerUserId { get; set; }
        public int? ReviewedUserId { get; set; }
        public int? Id { get; set; }
        public bool? IsApproved { get; set; }
        public bool? IsDenied { get; set; }
    }
}
