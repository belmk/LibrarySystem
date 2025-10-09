using Library.Models.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.SearchObjects
{
    public class ForumCommentSearchObject : BaseSearchObject
    {
        public int? ForumThreadId { get; set; }
        public string? Username { get; set; }
        public string? Comment { get; set; }
    }
}
