using System;
using System.Collections.Generic;
using System.Text;

namespace Library.Models.Email
{
    public sealed class UserRegisteredMessage
    {
        public int UserId { get; set; }
        public string Email { get; set; } = default!;
        public string UserName { get; set; } = default!;
        public string ActivateUrl { get; set; } = default!;
        public DateTime OccurredAtUtc { get; set; } = DateTime.UtcNow;
        public string CorrelationId { get; set; } = Guid.NewGuid().ToString("N");
    }
}