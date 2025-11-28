using AutoMapper;
using Library.Services.Database;
using Library.Services.Interfaces;
using Library.Services.Mappings;
using Library.Services.Services;
using LibraryBackend;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

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

app.Run();
