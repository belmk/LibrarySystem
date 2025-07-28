using Library.Models.DTOs.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.Notifications
{
    public class NotificationDto
    {
        public int Id { get; set; }
        public UserDto User { get; set; }
        public DateTime ReceivedDate { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
    }
}
