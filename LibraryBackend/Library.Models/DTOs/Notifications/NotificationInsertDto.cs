using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.Notifications
{
    public class NotificationInsertDto
    {
        public int UserId { get; set; }
        public DateTime ReceivedDate { get; set; } = DateTime.UtcNow;
        public string Title { get; set; }
        public string Message { get; set; }
    }
}
