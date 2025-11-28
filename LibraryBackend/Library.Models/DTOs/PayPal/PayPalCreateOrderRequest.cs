using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.PayPal
{
    public class PayPalCreateOrderRequest
    {
        public int UserId { get; set; }
        public decimal Price { get; set; }
        public int Days { get; set; }
    }

}
