using Library.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.BookExchanges
{
    public class BookExchangeUpdateDto
    {
        public bool? OfferUserAction { get; set; }
        public bool? ReceiverUserAction { get; set; }
        public BookExchangeStatus? BookExchangeStatus { get; set; }
    }
}
