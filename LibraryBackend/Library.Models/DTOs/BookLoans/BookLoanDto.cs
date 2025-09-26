using Library.Models.DTOs.Books;
using Library.Models.DTOs.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.BookLoans
{
    public class BookLoanDto
    {
        public int Id { get; set; }
        public UserDto User { get; set; }
        public BookDto Book { get; set; }
        public DateTime? LoanDate { get; set; }
        public DateTime? ReturnDate { get; set; }
        public bool IsApproved { get; set; }
    }
}
