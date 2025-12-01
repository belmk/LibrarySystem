using System;
using System.Collections.Generic;
using System.Text;

namespace Library.Models.Email
{
    public sealed class UserWelcomeEmailSent
    {
        public int UserId { get; set; }
        public string Email { get; set; } = default!;
        public DateTime SentAtUtc { get; set; }
        public string? CorrelationId { get; set; }
    }
}