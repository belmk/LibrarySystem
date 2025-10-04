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
                .Include(x => x.Book.Author)
                .Include(x => x.User);

            if (!string.IsNullOrWhiteSpace(search?.BookName))
            {
                filteredQuery = filteredQuery.Where(x => x.Book.Title.ToLower().Contains(search.BookName.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search?.Username))
            {
                filteredQuery = filteredQuery.Where(x => x.User.Username.Contains(search.Username));
            }

            if (search?.LoanDate != null && search.LoanDate != DateTime.MinValue) 
            {
                filteredQuery = filteredQuery.Where(x => x.LoanDate.Value.Date.Equals(search.LoanDate.Value.Date));
            }

            if (search?.LoanStatus != null) 
            { 
                filteredQuery = filteredQuery.Where(x => x.LoanStatus.Equals(search.LoanStatus));
            }

            if (search?.UserId != null) 
            { 
                filteredQuery = filteredQuery.Where(x => x.UserId.Equals(search.UserId));
            }


            return filteredQuery;
        }

        public override async Task BeforeUpdate(BookLoan entity, BookLoanUpdateDto update)
        {
            if (!update.LoanDate.HasValue && entity.LoanDate.HasValue)
            {
                update.LoanDate = entity.LoanDate;
            }

            if (!update.ReturnDate.HasValue && entity.ReturnDate.HasValue)
            {
                update.ReturnDate = entity.ReturnDate;
            }

            await base.BeforeUpdate(entity, update);
        }

    }
}
