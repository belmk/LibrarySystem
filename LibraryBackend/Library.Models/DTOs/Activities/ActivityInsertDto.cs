using Library.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.Activities
{
    public class ActivityInsertDto
    {
        public int UserId { get; set; }
        public string Description { get; set; }
        public DateTime ActivityDate { get; set; } = DateTime.Now;
    }
}
