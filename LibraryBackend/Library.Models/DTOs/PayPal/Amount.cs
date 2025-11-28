using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.PayPal
{
    public class Amount
    {
        public string Currency_Code { get; set; } = "EUR";  
        public string Value { get; set; }
    }
}
