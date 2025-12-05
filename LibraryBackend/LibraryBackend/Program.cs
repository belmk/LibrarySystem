using AutoMapper;
using EasyNetQ;
using Library.Services.Database;
using Library.Services.Interfaces;
using Library.Services.Mappings;
using Library.Services.Services;
using LibraryBackend;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);


string BuildRabbitConn(IConfiguration cfg)
{
    var fromSingle = cfg["RabbitMQ:ConnectionString"];
    if (!string.IsNullOrWhiteSpace(fromSingle)) return fromSingle;

    var host = cfg["Rabbit:Host"] ?? "localhost";
    var user = cfg["Rabbit:User"] ?? "guest";
    var pass = cfg["Rabbit:Pass"] ?? "guest";
    var port = cfg["Rabbit:Port"];
    var vhost = cfg["Rabbit:VirtualHost"];
    var product = cfg["Rabbit:Product"]; // optional label
    var name = cfg["Rabbit:Name"];    // optional label

    var parts = new List<string>
                {
                    $"host={host}",
                    $"username={user}",
                    $"password={pass}",
                    "publisherConfirms=true",
                    "timeout=10"
                };
    if (!string.IsNullOrWhiteSpace(port)) parts.Add($"port={port}");
    if (!string.IsNullOrWhiteSpace(vhost)) parts.Add($"virtualHost={vhost}");
    if (!string.IsNullOrWhiteSpace(product)) parts.Add($"product={product}");
    if (!string.IsNullOrWhiteSpace(name)) parts.Add($"name={name}");


    return string.Join(";", parts);


}

var rabbitConn = BuildRabbitConn(builder.Configuration);

Console.WriteLine($"RabbitMQ connection string: {rabbitConn}");

// Optionally, log individual components for clarity
Console.WriteLine($"Host: {builder.Configuration["Rabbit:Host"] ?? "localhost"}");
Console.WriteLine($"User: {builder.Configuration["Rabbit:User"] ?? "guest"}");
Console.WriteLine($"Pass: {builder.Configuration["Rabbit:Pass"] ?? "guest"}");
Console.WriteLine($"Port: {builder.Configuration["Rabbit:Port"] ?? "default"}");
Console.WriteLine($"VirtualHost: {builder.Configuration["Rabbit:VirtualHost"] ?? "/"}");
Console.WriteLine($"Product label: {builder.Configuration["Rabbit:Product"] ?? "<none>"}");
Console.WriteLine($"Name label: {builder.Configuration["Rabbit:Name"] ?? "<none>"}");


builder.Services.AddSingleton<IBus>(_ =>
    RabbitHutch.CreateBus(rabbitConn, cfg => cfg.EnableSystemTextJson())
);


// Add services to the container.
builder.Services.AddTransient<IBookService, BookService>();
builder.Services.AddTransient<IGenreService, GenreService>();
builder.Services.AddTransient<IAuthorService, AuthorService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<ISubscriptionService, SubscriptionService>();
builder.Services.AddTransient<IComplaintService, ComplaintService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IBookReviewService, BookReviewService>();
builder.Services.AddTransient<IForumThreadService, ForumThreadService>();
builder.Services.AddTransient<IForumCommentService, ForumCommentService>();
builder.Services.AddTransient<IActivityService,  ActivityService>();
builder.Services.AddTransient<IBookLoanService, BookLoanService>();
builder.Services.AddTransient<IBookExchangeService, BookExchangeService>();
builder.Services.AddTransient<IDashboardService, DashboardService>();
builder.Services.AddTransient<IUserReviewService, UserReviewService>();
builder.Services.AddTransient<IAuthService, AuthService>();

builder.Services.AddScoped<DatabaseSeeder>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAutoMapper(cfg =>
{
    cfg.AddProfile<MappingProfile>();
});
builder.Services.AddDbContext<LibraryDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "basic"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                { Type = ReferenceType.SecurityScheme, Id = "basicAuth" }
            },
            Array.Empty<string>()
        }
    });
});
builder.Services.AddAuthentication("BasicAuthentication")
       .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>(
           "BasicAuthentication", null);

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));
});

builder.Services.AddHttpClient();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
Console.WriteLine("DB: " + builder.Configuration.GetConnectionString("DefaultConnection"));

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var db = services.GetRequiredService<LibraryDbContext>();
    await db.Database.MigrateAsync();

    Console.WriteLine("Migration finished. Seeding data...");
    var seeder = services.GetRequiredService<DatabaseSeeder>();
    seeder.Seed();
}

app.Run();
