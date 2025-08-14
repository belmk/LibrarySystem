using Library.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.Activities
{
    public class ActivityUpdateDto
    {
        public string Description { get; set; }
        public DateTime ActivityDate { get; set; }
    }
}
