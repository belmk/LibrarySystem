using Library.Models.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.SearchObjects
{
    public class ForumThreadSearchObject : BaseSearchObject
    {
        public string? ForumTitle { get; set; }
        public string? BookTitle { get; set; }
        public string? Username { get; set; }

    }
}
