using Library.Models.Base;
using Library.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.SearchObjects
{
    public class ActivitySearchObject : BaseSearchObject
    {
        public string? Description { get; set; }
        public string? Email { get; set; }
    }
}
