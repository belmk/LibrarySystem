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

    }
}
