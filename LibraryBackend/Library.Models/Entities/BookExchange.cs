using Library.Models.Enums;
using Library.Services.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.Entities
{
    public class BookExchange
    {
        public int Id { get; set; }

        public int OfferUserId { get; set; }
        public User OfferUser { get; set; }

        public int ReceiverUserId { get; set; }
        public User ReceiverUser { get; set; }

        public int OfferBookId { get; set; }
        public Book OfferBook { get; set; }

        public int ReceiverBookId { get; set; }
        public Book ReceiverBook { get; set; }

        public bool OfferUserAction { get; set; } = false;
        public bool ReceiverUserAction { get; set; } = false;
        public BookExchangeStatus BookExchangeStatus { get; set; } = BookExchangeStatus.PendingApproval;

    }
}
