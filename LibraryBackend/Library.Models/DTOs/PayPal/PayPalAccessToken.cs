using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.PayPal
{
    public class PayPalAccessToken
    {
        public string Scope { get; set; }
        public string Access_Token { get; set; }
        public string Token_Type { get; set; }
        public string App_Id { get; set; }
        public int Expires_In { get; set; }
    }

}
