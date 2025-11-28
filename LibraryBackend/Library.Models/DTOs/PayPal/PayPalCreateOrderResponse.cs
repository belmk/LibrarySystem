using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.PayPal
{
    public class PayPalCreateOrderResponse
    {
        public string Id { get; set; }
        public List<PayPalLink> Links { get; set; }
    }
}
