using Library.Models.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.SearchObjects
{
    public class BookSearchObject : BaseSearchObject
    {
        public string? Title { get; set; }
        public string? Author { get; set; }
        public int? GenreId { get; set; }
        public bool? IsUserBook { get; set; } 
        public int? UserId { get; set; }
        public string? Username { get; set; }
    }
}
