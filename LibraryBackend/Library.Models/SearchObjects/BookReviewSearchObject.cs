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
        public string? Email {  get; set; }
    }
}
