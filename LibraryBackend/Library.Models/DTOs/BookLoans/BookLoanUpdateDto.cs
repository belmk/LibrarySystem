using Library.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.BookLoans
{
    public class BookLoanUpdateDto
    {
        public DateTime? LoanDate { get; set; }
        public DateTime? ReturnDate { get; set; }
        public BookLoanStatus LoanStatus { get; set; }

    }
}
