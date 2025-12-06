using EasyNetQ;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using MimeKit;
using Library.Subscriber;
using Library.Models.Email;

namespace Library.Subscribers;

public sealed class EmailSubscriber : BackgroundService
{
    private readonly IBus _bus;
    private readonly ILogger<EmailSubscriber> _log;
    private readonly SmtpOptions _smtp;
    private readonly EmailOptions _email;

    private IDisposable? _subscription;

    public EmailSubscriber(
        IBus bus,
        IOptions<SmtpOptions> smtpOpt,
        IOptions<EmailOptions> emailOpt,
        ILogger<EmailSubscriber> log)
    {
        _bus = bus;
        _smtp = smtpOpt.Value;
        _email = emailOpt.Value;
        _log = log;

        _log.LogInformation("SMTP config → Host={Host} Port={Port} User={User} StartTLS={StartTls}",
            _smtp.Host, _smtp.Port, _smtp.User ?? "<none>", _smtp.UseStartTls);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _log.LogInformation("Email worker starting…");

        IDisposable? subscription = null;

        while (subscription is null && !stoppingToken.IsCancellationRequested)
        {
            try
            {
                _log.LogInformation("Subscribing to UserRegisteredMessage…");
                subscription = await _bus.PubSub.SubscribeAsync<UserRegisteredMessage>(
                    subscriptionId: "eLibrary.emailer.v1",
                    onMessage: msg => SendWelcomeMail(msg, stoppingToken),
                    configure: cfg => cfg.WithPrefetchCount(1),
                    cancellationToken: stoppingToken
                );
                _log.LogInformation("Subscribed. Waiting for messages…");
            }
            catch (OperationCanceledException)
            {
                // shutting down
                return;
            }
            catch (Exception ex)
            {
                _log.LogWarning(ex, "RabbitMQ not ready yet (subscribe failed). Retrying in 5s…");
                try { await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken); } catch { return; }
            }
        }

        try { await Task.Delay(Timeout.Infinite, stoppingToken); }
        catch (OperationCanceledException) { /* stopping */ }

        subscription?.Dispose();
    }

    public override Task StopAsync(CancellationToken cancellationToken)
    {
        _subscription?.Dispose();
        _subscription = null;
        return base.StopAsync(cancellationToken);
    }

    private async Task SendWelcomeMail(UserRegisteredMessage msg, CancellationToken ct)
    {
        _log.LogInformation("Preparing welcome email for {Email}", msg.Email);

        var mime = new MimeMessage();

        var fromDisplay = string.IsNullOrWhiteSpace(_email.From)
            ? $"eLibrary <{_smtp.User}>"
            : _email.From;

        try { mime.From.Add(MailboxAddress.Parse(fromDisplay)); }
        catch { mime.From.Add(MailboxAddress.Parse(_smtp.User!)); }

        mime.To.Add(MailboxAddress.Parse(msg.Email));
        mime.Subject = string.IsNullOrWhiteSpace(_email.Subject)
            ? "Dobrodošli u eLibrary!"
            : _email.Subject;

        var bodyBuilder = new BodyBuilder
        {
            TextBody = $"Pozdrav {msg.UserName},\n\n" +
                       "Hvala što ste se registrovali u eLibrary.\n" +
                       "Sada se možete prijaviti koristeći mobilnu aplikaciju.\n\n" +
                       "Ako niste tražili ovu registraciju, možete ignorisati ovaj email.",

            HtmlBody = $@"
                <html>
                    <body style=""font-family:Arial,Helvetica,sans-serif; font-size:14px; color:#222;"">
                        <p>Pozdrav {System.Net.WebUtility.HtmlEncode(msg.UserName)},</p>
                        <p>Hvala što ste se registrovali u <strong>eLibrary</strong>.</p>
                        <p>Sada se možete prijaviti koristeći mobilnu aplikaciju.</p>
                        <p style=""color:#666"">Ako niste tražili ovu registraciju, možete ignorisati ovaj email.</p>
                    </body>
                </html>"
                };


        mime.Body = bodyBuilder.ToMessageBody();

        using var smtp = new SmtpClient();
        var secureOpt = _smtp.UseStartTls ? SecureSocketOptions.StartTls : SecureSocketOptions.None;

        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(30));
        using var linked = CancellationTokenSource.CreateLinkedTokenSource(ct, timeout.Token);

        try
        {
            await smtp.ConnectAsync(_smtp.Host, _smtp.Port, secureOpt, linked.Token);

            if (!string.IsNullOrWhiteSpace(_smtp.User))
                await smtp.AuthenticateAsync(_smtp.User, _smtp.Pass, linked.Token);

            _log.LogInformation("Sending email → Subject='{Subject}', TextLen={TextLen}, HtmlLen={HtmlLen}",
                mime.Subject, bodyBuilder.TextBody?.Length ?? 0, bodyBuilder.HtmlBody?.Length ?? 0);

            await smtp.SendAsync(mime, linked.Token);
            await smtp.DisconnectAsync(true, linked.Token);

            _log.LogInformation("Email successfully sent to {Email}", msg.Email);

            await _bus.PubSub.PublishAsync(new UserWelcomeEmailSent
            {
                UserId = msg.UserId,
                Email = msg.Email,
                SentAtUtc = DateTime.UtcNow
            }, cancellationToken: ct);
        }
        catch (OperationCanceledException)
        {
            _log.LogWarning("SMTP send canceled or timed out for {Email}", msg.Email);
        }
        catch (Exception ex)
        {
            _log.LogError(ex, "Failed to send email to {Email}", msg.Email);
        }
    }
}