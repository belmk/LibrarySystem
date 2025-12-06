using Library.Models.Entities;
using Library.Models.Enums;
using Library.Services.Entities;
using Library.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Database
{
    public class DatabaseSeeder
    {
        private readonly LibraryDbContext _context;

        public DatabaseSeeder(LibraryDbContext context)
        {
            _context = context;
        }

        public void Seed()
        {
            AddRoles();
            AddAuthors();
            AddGenres();
            AddBooks();
            AddUsers();
            AddBookReviews();
            AddSubscriptions();
            AddUserReviews();
            AddBookLoans();
            AddUserBooks();
        }

        private void AddRoles()
        {
            if (!_context.Roles.Any())
            {
                _context.Roles.AddRange(
                    new Role { Name = "Admin" },
                    new Role { Name = "User" }
                );
                _context.SaveChanges();
            }
        }

        private void AddAuthors()
        {
            if (!_context.Authors.Any())
            {
                _context.Authors.AddRange(
                    new Author { FirstName = "George", LastName = "Orwell" },
                    new Author { FirstName = "J.K.", LastName = "Rowling" },
                    new Author { FirstName = "Jane", LastName = "Austen" },
                    new Author { FirstName = "Mark", LastName = "Twain" },
                    new Author { FirstName = "Ernest", LastName = "Hemingway" },
                    new Author { FirstName = "Agatha", LastName = "Christie" }
                );
                _context.SaveChanges();
            }
        }


        private void AddGenres()
        {
            if (!_context.Genres.Any())
            {
                _context.Genres.AddRange(
                    new Genre { Name = "Distopijski" },
                    new Genre { Name = "Fantazija" },
                    new Genre { Name = "Klasici" },
                    new Genre { Name = "Drama" },
                    new Genre { Name = "Krimi" },
                    new Genre { Name = "Avantura" },
                    new Genre { Name = "Komedija" },
                    new Genre { Name = "Naučna fantastika" },
                    new Genre { Name = "Horor" }
                );

                _context.SaveChanges();
            }
        }


        private void AddBooks()
        {
            if (!_context.Books.Any())
            {
                var orwell = _context.Authors.First(a => a.LastName == "Orwell");
                var rowling = _context.Authors.First(a => a.LastName == "Rowling");
                var austen = _context.Authors.First(a => a.LastName == "Austen");
                var twain = _context.Authors.First(a => a.LastName == "Twain");
                var hemingway = _context.Authors.First(a => a.LastName == "Hemingway");
                var christie = _context.Authors.First(a => a.LastName == "Christie");

                var distopijski = _context.Genres.First(g => g.Name == "Distopijski");
                var fantazija = _context.Genres.First(g => g.Name == "Fantazija");
                var klasici = _context.Genres.First(g => g.Name == "Klasici");
                var drama = _context.Genres.First(g => g.Name == "Drama");
                var krimi = _context.Genres.First(g => g.Name == "Krimi");
                var avantura = _context.Genres.First(g => g.Name == "Avantura");

                var book1 = new Book
                {
                    Title = "1984",
                    Author = orwell,
                    Description = "Distopijski roman o totalitarnoj državi i neprestanom nadzoru nad građanima.",
                    PageNumber = 328,
                    AvailableNumber = 5
                };
                book1.Genres.Add(distopijski);

                var book2 = new Book
                {
                    Title = "Harry Potter i Kamen Mudraca",
                    Author = rowling,
                    Description = "Fantazijska priča o dječaku koji otkriva da je čarobnjak i ulazi u magični svijet.",
                    PageNumber = 309,
                    AvailableNumber = 10
                };
                book2.Genres.Add(fantazija);

                var book3 = new Book
                {
                    Title = "Ponos i Predrasuda",
                    Author = austen,
                    Description = "Klasik britanske književnosti o ljubavi, društvu i predrasudama 19. stoljeća.",
                    PageNumber = 279,
                    AvailableNumber = 6
                };
                book3.Genres.Add(klasici);
                book3.Genres.Add(drama);

                var book4 = new Book
                {
                    Title = "Avanture Toma Sojera",
                    Author = twain,
                    Description = "Avanturistički roman o dječaku koji stalno upada u nevolje i doživljava nezaboravne pustolovine.",
                    PageNumber = 224,
                    AvailableNumber = 7
                };
                book4.Genres.Add(avantura);

                var book5 = new Book
                {
                    Title = "Starac i More",
                    Author = hemingway,
                    Description = "Inspirativna priča o borbi starog ribara protiv ogromne ribe i vlastitih granica.",
                    PageNumber = 127,
                    AvailableNumber = 4
                };
                book5.Genres.Add(drama);

                var book6 = new Book
                {
                    Title = "Ubistvo u Orient Expressu",
                    Author = christie,
                    Description = "Kriminalistički roman u kojem Hercule Poirot rješava misteriozno ubistvo u luksuznom vozu.",
                    PageNumber = 256,
                    AvailableNumber = 8
                };
                book6.Genres.Add(krimi);

                _context.Books.AddRange(book1, book2, book3, book4, book5, book6);
                _context.SaveChanges();
            }
        }



        private void AddUsers()
        {
            if (!_context.Users.Any())
            {
                var adminRole = _context.Roles.FirstOrDefault(r => r.Name == "Admin");
                var userRole = _context.Roles.FirstOrDefault(r => r.Name == "User");

                if (adminRole == null || userRole == null)
                {
                    throw new InvalidOperationException("Roles must exist before creating users.");
                }


                var adminSalt = UserService.GenerateSalt();
                var admin = new User
                {
                    FirstName = "Admin",
                    LastName = "Adminović",
                    Username = "admin",
                    Email = "admin@example.com",
                    RoleId = adminRole.Id,
                    PasswordSalt = adminSalt,
                    PasswordHash = UserService.GenerateHash(adminSalt, "admin"),
                    RegistrationDate = DateTime.UtcNow,
                    IsActive = true,
                    WarningNumber = 0
                };

                var userSalt = UserService.GenerateSalt();
                var user = new User
                {
                    FirstName = "Korisnik",
                    LastName = "Koristić",
                    Username = "user",
                    Email = "user@example.com",
                    RoleId = userRole.Id,
                    PasswordSalt = userSalt,
                    PasswordHash = UserService.GenerateHash(userSalt, "user"),
                    RegistrationDate = DateTime.UtcNow.AddDays(-3),
                    IsActive = true,
                    WarningNumber = 0
                };


                var users = new List<User>();

                var salt1 = UserService.GenerateSalt();
                users.Add(new User
                {
                    FirstName = "John",
                    LastName = "Doe",
                    Username = "john",
                    Email = "john@example.com",
                    RoleId = userRole.Id,
                    PasswordSalt = salt1,
                    PasswordHash = UserService.GenerateHash(salt1, "john123"),
                    RegistrationDate = DateTime.UtcNow.AddDays(-44),
                    IsActive = true,
                    WarningNumber = 0
                });

                var salt2 = UserService.GenerateSalt();
                users.Add(new User
                {
                    FirstName = "Emily",
                    LastName = "Smith",
                    Username = "emily",
                    Email = "emily@example.com",
                    RoleId = userRole.Id,
                    PasswordSalt = salt2,
                    PasswordHash = UserService.GenerateHash(salt2, "emily123"),
                    RegistrationDate = DateTime.UtcNow.AddDays(-15),
                    IsActive = true,
                    WarningNumber = 0
                });

                var salt3 = UserService.GenerateSalt();
                users.Add(new User
                {
                    FirstName = "Michael",
                    LastName = "Brown",
                    Username = "michael",
                    Email = "michael@example.com",
                    RoleId = userRole.Id,
                    PasswordSalt = salt3,
                    PasswordHash = UserService.GenerateHash(salt3, "michael123"),
                    RegistrationDate = DateTime.UtcNow.AddDays(-102),
                    IsActive = true,
                    WarningNumber = 0
                });

                var salt4 = UserService.GenerateSalt();
                users.Add(new User
                {
                    FirstName = "Sarah",
                    LastName = "Johnson",
                    Username = "sarah",
                    Email = "sarah@example.com",
                    RoleId = userRole.Id,
                    PasswordSalt = salt4,
                    PasswordHash = UserService.GenerateHash(salt4, "sarah123"),
                    RegistrationDate = DateTime.UtcNow.AddDays(-35),
                    IsActive = true,
                    WarningNumber = 0
                });

                var salt5 = UserService.GenerateSalt();
                users.Add(new User
                {
                    FirstName = "David",
                    LastName = "Miller",
                    Username = "david",
                    Email = "david@example.com",
                    RoleId = userRole.Id,
                    PasswordSalt = salt5,
                    PasswordHash = UserService.GenerateHash(salt5, "david123"),
                    RegistrationDate = DateTime.UtcNow,
                    IsActive = true,
                    WarningNumber = 0
                });

                _context.Users.Add(admin);
                _context.Users.Add(user);
                _context.Users.AddRange(users);
                _context.SaveChanges();
            }
        }

        private void AddBookReviews()
        {
            if (!_context.BookReviews.Any())
            {
                var books = _context.Books.ToList();
                var users = _context.Users.ToList();

                if (!books.Any() || !users.Any())
                    return;

                var random = new Random();
                var comments = new List<string>
        {
            "Odlična knjiga, toplo preporučujem!",
            "Vrlo zanimljiva i dobro napisana.",
            "Prijatno iznenađenje, uživao sam u čitanju.",
            "Solidna knjiga, ali ima prostora za poboljšanje.",
            "Nisam očekivao ovakav ishod, baš dobra priča!",
            "Pomalo sporo na početku, ali kasnije jako dobra."
        };

                var reviewsToAdd = new List<BookReview>();

                foreach (var book in books)
                {
                    int reviewCount = random.Next(2, 4);
                    var selectedUsers = users.OrderBy(x => Guid.NewGuid())
                                             .Take(reviewCount)
                                             .ToList();

                    foreach (var user in selectedUsers)
                    {
                        bool alreadyReviewed = _context.BookReviews
                            .Any(r => r.BookId == book.Id && r.UserId == user.Id);

                        if (alreadyReviewed)
                            continue;

                        var review = new BookReview
                        {
                            BookId = book.Id,
                            UserId = user.Id,
                            Rating = random.Next(3, 6), 
                            Comment = comments[random.Next(comments.Count)],
                            ReviewDate = DateTime.UtcNow.AddDays(-random.Next(1, 200)),
                            IsApproved = true,
                            IsDenied = false
                        };

                        reviewsToAdd.Add(review);
                    }
                }

                if (reviewsToAdd.Any())
                {
                    _context.BookReviews.AddRange(reviewsToAdd);
                    _context.SaveChanges();
                }
            }
        }

        private void AddSubscriptions()
        {
            if (!_context.Subscriptions.Any())
            {
                var users = _context.Users.ToList();
                if (!users.Any())
                    return;

                var random = new Random();

                var subscriptionOptions = new List<(int Days, decimal Price)>
        {
            (7, 10m),
            (30, 30m),
            (90, 50m)
        };

                var subscriptionsToAdd = new List<Subscription>();

                foreach (var user in users)
                {
                    int subscriptionCount = random.Next(1, 4);

                    DateTime lastEndDate = DateTime.UtcNow.AddDays(-random.Next(30, 400));

                    for (int i = 0; i < subscriptionCount; i++)
                    {
                        var option = subscriptionOptions[random.Next(subscriptionOptions.Count)];

                        var startDate = lastEndDate.AddDays(random.Next(1, 10)); 
                        var endDate = startDate.AddDays(option.Days);

                        var subscription = new Subscription
                        {
                            UserId = user.Id,
                            StartDate = startDate,
                            EndDate = endDate,
                            Price = option.Price,
                            IsCancelled = false
                        };

                        subscriptionsToAdd.Add(subscription);

                        lastEndDate = endDate;
                    }
                }

                _context.Subscriptions.AddRange(subscriptionsToAdd);
                _context.SaveChanges();
            }
        }

        private void AddUserReviews()
        {
            if (!_context.UserReviews.Any())
            {
                var users = _context.Users.ToList();
                if (!users.Any() || users.Count < 2)
                    return;

                var random = new Random();

                var comments = new List<string>
        {
            "Odlična saradnja, sve preporuke!",
            "Korektan i pouzdan korisnik.",
            "Vrlo pozitivno iskustvo.",
            "Dobra komunikacija i brz dogovor.",
            "Sve proteklo bez problema.",
            "Mala kašnjenja, ali sve u redu na kraju."
        };

                var reviewsToAdd = new List<UserReview>();

                foreach (var reviewer in users)
                {
                    int reviewCount = random.Next(1, 4);

                    var possibleReviewed = users.Where(u => u.Id != reviewer.Id)
                                                .OrderBy(u => Guid.NewGuid())
                                                .Take(reviewCount);

                    foreach (var reviewedUser in possibleReviewed)
                    {
                        bool exists = _context.UserReviews.Any(r =>
                            r.ReviewerUserId == reviewer.Id &&
                            r.ReviewedUserId == reviewedUser.Id);

                        if (exists)
                            continue;

                        var review = new UserReview
                        {
                            ReviewerUserId = reviewer.Id,
                            ReviewedUserId = reviewedUser.Id,
                            Rating = random.Next(3, 6), // Good ratings (3–5)
                            Comment = comments[random.Next(comments.Count)],
                            ReviewDate = DateTime.UtcNow.AddDays(-random.Next(1, 400)),
                            IsApproved = true,
                            IsDenied = false
                        };

                        reviewsToAdd.Add(review);
                    }
                }

                if (reviewsToAdd.Any())
                {
                    _context.UserReviews.AddRange(reviewsToAdd);
                    _context.SaveChanges();
                }
            }
        }

        private void AddBookLoans()
        {
            if (!_context.BookLoans.Any())
            {
                var users = _context.Users.ToList();
                var books = _context.Books.ToList();

                if (!users.Any() || !books.Any())
                    return;

                var random = new Random();
                var bookLoansToAdd = new List<BookLoan>();

                foreach (var user in users)
                {
                    var availableBooks = books.Where(b => b.AvailableNumber > 0).ToList();
                    if (!availableBooks.Any())
                        break; 

                    var book = availableBooks[random.Next(availableBooks.Count)];

                    var loanDate = DateTime.UtcNow.AddDays(-random.Next(1, 30));

                    var returnDate = loanDate.AddDays(random.Next(7, 15));

                    var bookLoan = new BookLoan
                    {
                        UserId = user.Id,
                        BookId = book.Id,
                        LoanDate = loanDate,
                        ReturnDate = returnDate,
                        LoanStatus = BookLoanStatus.Returned
                    };

                    bookLoansToAdd.Add(bookLoan);

                }

                if (bookLoansToAdd.Any())
                {
                    _context.BookLoans.AddRange(bookLoansToAdd);
                    _context.SaveChanges();
                }
            }
        }

        private void AddUserBooks()
        {
            if (!_context.Books.Any(b => b.IsUserBook))
            {
                var users = _context.Users.ToList();
                if (!users.Any())
                    return;

                var random = new Random();
                var userBooksToAdd = new List<Book>();

                int numberOfUserBooks = Math.Min(3, users.Count);

                for (int i = 0; i < numberOfUserBooks; i++)
                {
                    var user = users[random.Next(users.Count)];

                    var author = _context.Authors.OrderBy(a => Guid.NewGuid()).FirstOrDefault();
                    if (author == null)
                        return;

                    var userBook = new Book
                    {
                        Title = $"Korisnička knjiga {i + 1}",
                        Description = "Ovo je knjiga dodana od strane korisnika.",
                        PageNumber = random.Next(50, 500),
                        AvailableNumber = 1,
                        AuthorId = author.Id, 
                        IsUserBook = true,
                        UserId = user.Id,
                        CoverImage = null,
                        CoverImageContentType = null
                    };


                    userBooksToAdd.Add(userBook);
                }

                _context.Books.AddRange(userBooksToAdd);
                _context.SaveChanges();
            }
        }


    }
}
