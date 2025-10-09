using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.BookExchanges
{
    public class BookExchangeInsertDto
    {
        public int OfferUserId { get; set; }
        public int ReceiverUserId { get; set; }
        public int OfferBookId { get; set; }
        public int ReceiverBookId { get; set; }

    }
}
