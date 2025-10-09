using Library.Models.Base;
using Library.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.SearchObjects
{
    public class BookExchangeSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public string? Email { get; set; }
        public string? Title { get; set; }
        public BookExchangeStatus? BookExchangeStatus { get; set; }
    }
}
