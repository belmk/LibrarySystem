using Library.Models.DTOs.Authors;
using Library.Models.DTOs.Genres;
using Library.Models.DTOs.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.UserBooks
{
    public class UserBookDto
    {
        public int Id { get; set; }
        public AuthorDto Author { get; set; }
        public UserDto User { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int PageNumber { get; set; }
        public int AvailableNumber { get; set; }
        public ICollection<GenreDto> Genres { get; set; } = new List<GenreDto>();
    }
}
