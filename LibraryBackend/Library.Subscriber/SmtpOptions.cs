using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Subscriber
{
    public sealed class SmtpOptions
    {
        public required string Host { get; init; }
        public int Port { get; init; } = 587;
        public bool UseStartTls { get; init; } = true;
        public string? User { get; init; }
        public string? Pass { get; init; }
    }

    public sealed class EmailOptions
    {
        public required string From { get; set; }
        public required string Subject { get; set; }
    }
}