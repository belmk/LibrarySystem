using Library.Models.Entities;
using Library.Services.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Database
{
    public class LibraryDbContext : DbContext
    {
        public LibraryDbContext(DbContextOptions<LibraryDbContext> options)
        : base(options) { }

        public DbSet<Role> Roles { get; set; }
        public DbSet<Book> Books { get; set; }
        public DbSet<Author> Authors { get; set; }
        public DbSet<Genre> Genres { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Subscription> Subscriptions { get; set; }
        public DbSet<Complaint> Complaints { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<BookReview> BookReviews { get; set; }
        public DbSet<ForumThread> ForumThreads { get; set; }
        public DbSet<ForumComment> ForumComments { get; set; }
        public DbSet<BookLoan> BookLoans { get; set; }
        public DbSet<Activity> Activities { get; set; }
        public DbSet<BookExchange> BookExchanges { get; set; }
        public DbSet<UserReview> UserReviews { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Complaint>()
                .HasOne(c => c.Sender)
                .WithMany()
                .HasForeignKey(c => c.SenderId)
                .OnDelete(DeleteBehavior.Restrict); 

            modelBuilder.Entity<Complaint>()
                .HasOne(c => c.Target)
                .WithMany()
                .HasForeignKey(c => c.TargetId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ForumComment>()
                .HasOne(fc => fc.User)
                .WithMany()
                .HasForeignKey(fc => fc.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ForumThread>()
                .HasOne(ft => ft.User)
                .WithMany()
                .HasForeignKey(ft => ft.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ForumComment>()
                .HasOne(fc => fc.ForumThread)
                .WithMany()
                .HasForeignKey(fc => fc.ForumThreadId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<BookExchange>()
                .HasOne(be => be.OfferBook)
                .WithMany()
                .HasForeignKey(be => be.OfferBookId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<BookExchange>()
                .HasOne(be => be.ReceiverBook)
                .WithMany()
                .HasForeignKey(be => be.ReceiverBookId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<BookExchange>()
                .HasOne(be => be.OfferUser)
                .WithMany()
                .HasForeignKey(be => be.OfferUserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<BookExchange>()
                .HasOne(be => be.ReceiverUser)
                .WithMany()
                .HasForeignKey(be => be.ReceiverUserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<UserReview>()
                .HasOne(ur => ur.ReviewedUser)
                .WithMany()
                .HasForeignKey(ur => ur.ReviewedUserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<UserReview>()
                .HasOne(ur => ur.ReviewerUser)
                .WithMany()
                .HasForeignKey(ur => ur.ReviewerUserId)
                .OnDelete(DeleteBehavior.Restrict);

        }

    }
}
