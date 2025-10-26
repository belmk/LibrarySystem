using Library.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Entities
{
    public class Book
    {
        public int Id { get; set; }
        public int AuthorId { get; set; }
        public Author Author { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int PageNumber { get; set; }
        public int AvailableNumber { get; set; }
        public ICollection<Genre> Genres { get; set; } = new List<Genre>();

        public bool IsUserBook { get; set; } = false; 
        public int? UserId { get; set; } 
        public User? User { get; set; }

        public byte[]? CoverImage { get; set; }            
        public string? CoverImageContentType { get; set; }
    }
}
