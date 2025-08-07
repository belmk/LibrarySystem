using Library.Models.DTOs.Books;
using Library.Models.DTOs.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.ForumThreads
{
    public class ForumThreadDto
    {
        public int Id { get; set; }
        public UserDto User { get; set; }
        public BookDto Book { get; set; }
        public string Title { get; set; }
        public DateTime ThreadDate { get; set; }
    }
}
