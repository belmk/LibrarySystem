using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.BookLoans
{
    public class BookLoanInsertDto
    {
        public int UserId { get; set; }
        public int BookId { get; set; }
    }
}
