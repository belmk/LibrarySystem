using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.Base
{
    public class PagedResult<T>
    {
        public List<T> Result { get; set; } = new List<T>();
        public int? Count { get; set; }
    }
}
