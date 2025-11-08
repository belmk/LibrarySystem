using Library.Models.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.SearchObjects
{
    public class BookReviewSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public int? BookId { get; set; }
        public string? Email {  get; set; }
        public DateTime? ReviewDate { get; set; }
        public bool? IsApproved { get; set; }
        public bool? IsDenied { get; set; }
    }
}
