using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.Complaints
{
    public class ComplaintInsertDto
    {
        public int SenderId { get; set; }
        public int TargetId { get; set; }
        public string Reason { get; set; }
        public DateTime ComplaintDate { get; set; } = DateTime.UtcNow;
        public bool IsResolved { get; set; } = false;
    }
}
