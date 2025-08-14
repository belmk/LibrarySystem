using Library.Models.DTOs.Users;
using Library.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.Activities
{
    public class ActivityDto
    {
        public int Id { get; set; }
        public UserDto User { get; set; }
        public string Description { get; set; }
        public DateTime ActivityDate { get; set; }
    }
}
