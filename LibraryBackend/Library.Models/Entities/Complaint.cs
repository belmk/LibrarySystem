using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.Entities
{
    public class Complaint
    {
        public int Id { get; set; }
        public int SenderId { get; set; } 
        public User Sender { get; set; }
        public int TargetId { get; set; }  
        public User Target { get; set; }
        public string Reason { get; set; }
        public DateTime ComplaintDate { get; set; }
        public bool IsResolved { get; set; }
    }
}
