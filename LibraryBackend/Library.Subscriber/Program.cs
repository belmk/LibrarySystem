using DotNetEnv;
using EasyNetQ;
using EasyNetQ.Serialization.SystemTextJson;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Library.Subscriber;
using Library.Subscribers;

var builder = Host.CreateApplicationBuilder(args);

var localEnvPath = Path.Combine(builder.Environment.ContentRootPath, ".env");
if (File.Exists(localEnvPath)) Env.Load(localEnvPath);

builder.Configuration.Sources.Clear();
builder.Configuration.AddEnvironmentVariables();

builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.SetMinimumLevel(LogLevel.Information);

builder.Services.Configure<SmtpOptions>(builder.Configuration.GetSection("Smtp"));
builder.Services.Configure<EmailOptions>(builder.Configuration.GetSection("Email"));

var smtp = builder.Configuration.GetSection("Smtp").Get<SmtpOptions>()
          ?? throw new InvalidOperationException("Missing Smtp__* env vars.");
if (string.IsNullOrWhiteSpace(smtp.Host)) throw new ArgumentException("Smtp__Host is required.");
if (smtp.Port <= 0) throw new ArgumentException("Smtp__Port is required.");

var rabbitHost = builder.Configuration["RabbitMQ:Host"] ?? "localhost";
var rabbitUser = builder.Configuration["RabbitMQ:Username"] ?? "guest";
var rabbitPass = builder.Configuration["RabbitMQ:Password"] ?? "guest";
var rabbitPort = builder.Configuration["RabbitMQ:Port"];
var rabbitVh = builder.Configuration["RabbitMQ:VirtualHost"];


var parts = new List<string> { $"host={rabbitHost}", $"username={rabbitUser}", $"password={rabbitPass}" };
if (!string.IsNullOrWhiteSpace(rabbitPort)) parts.Add($"port={rabbitPort}");
if (!string.IsNullOrWhiteSpace(rabbitVh)) parts.Add($"virtualHost={rabbitVh}");
parts.Add("publisherConfirms=true");
parts.Add("timeout=10");

var rabbitConnString = string.Join(";", parts);

builder.Services.AddSingleton<IBus>(_ =>
    RabbitHutch.CreateBus(rabbitConnString, cfg => cfg.EnableSystemTextJson())
);

builder.Services.AddHostedService<EmailSubscriber>();

await builder.Build().RunAsync();