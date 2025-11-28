using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.PayPal
{
    public class PayPalOrderRequest
    {
        public string Intent { get; set; } = "CAPTURE";
        public PurchaseUnit[] Purchase_Units { get; set; }
    }
}
