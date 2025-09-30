using Library.Models.Base;
using Library.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.SearchObjects
{
    public class BookLoanSearchObject : BaseSearchObject
    {
        public string? BookName { get; set; }
        public string? Username { get; set; }
        public DateTime? LoanDate { get; set; }
        public DateTime? ReturnDate { get; set; }
        public BookLoanStatus? LoanStatus { get; set; }
    }
}
