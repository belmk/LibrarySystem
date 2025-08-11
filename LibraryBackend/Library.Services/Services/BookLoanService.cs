using AutoMapper;
using Library.Models.DTOs.BookLoans;
using Library.Models.Entities;
using Library.Models.SearchObjects;
using Library.Services.Database;
using Library.Services.Entities;
using Library.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Services
{
    public class BookLoanService : BaseCRUDService<BookLoanDto, BookLoan, BookLoanSearchObject, BookLoanInsertDto, BookLoanUpdateDto>, IBookLoanService
    {
        public BookLoanService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<BookLoan> AddFilter(IQueryable<BookLoan> query, BookLoanSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery
                .Include(x => x.Book)
                .Include(x => x.User);

            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Email.Contains(search.Email));
            }

            if (!string.IsNullOrWhiteSpace(search?.Username))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Username.Contains(search.Username));
            }

            if (search?.LoanDate != null) 
            {
                filteredQuery = filteredQuery.Where(x => x.LoanDate.Equals(search.LoanDate));
            }

            return filteredQuery;
        }
    }
}
