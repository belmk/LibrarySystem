using Library.Models.DTOs.Books;
using Library.Models.DTOs.Users;
using Library.Models.Enums;
using Library.Services.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.BookExchanges
{
    public class BookExchangeDto
    {
        public int Id { get; set; }
        public UserDto OfferUser { get; set; }
        public UserDto ReceiverUser { get; set; }
        public BookDto OfferBook { get; set; }
        public BookDto ReceiverBook { get; set; }
        public bool OfferUserAction { get; set; }
        public bool ReceiverUserAction { get; set; }
        public BookExchangeStatus BookExchangeStatus { get; set; }
    }
}
