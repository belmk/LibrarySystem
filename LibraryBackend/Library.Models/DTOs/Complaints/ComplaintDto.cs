using Library.Models.DTOs.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.Complaints
{
    public class ComplaintDto
    {
        public int Id { get; set; }
        public UserDto Sender { get; set; }
        public UserDto Target {  get; set; }
        public string Reason { get; set; }
        public DateTime ComplaintDate { get; set; }
        public bool IsResolved { get; set; }

    }
}
