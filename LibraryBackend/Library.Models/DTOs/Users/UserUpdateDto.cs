using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.Users
{
    public class UserUpdateDto
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public int WarningNumber { get; set; }
        public bool IsActive { get; set; } = true;

    }
}
