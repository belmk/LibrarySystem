using AutoMapper;
using Library.Models.DTOs.BookExchanges;
using Library.Models.Entities;
using Library.Models.Enums;
using Library.Models.SearchObjects;
using Library.Services.Database;
using Library.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Services
{
    public class BookExchangeService : BaseCRUDService<BookExchangeDto, BookExchange, BookExchangeSearchObject, BookExchangeInsertDto, BookExchangeUpdateDto>, IBookExchangeService
    {
        public BookExchangeService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<BookExchange> AddFilter(IQueryable<BookExchange> query, BookExchangeSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery.Include(x => x.OfferUser).Include(x => x.ReceiverUser);
            filteredQuery = filteredQuery.Include(x => x.OfferBook).Include(x => x.ReceiverBook);

            filteredQuery = filteredQuery.Include(x => x.OfferBook.Genres).Include(x => x.ReceiverBook.Genres);
            filteredQuery = filteredQuery.Include(x => x.OfferBook.Author).Include(x => x.ReceiverBook.Author);

            if (!string.IsNullOrWhiteSpace(search?.Username)) 
            {
                filteredQuery = filteredQuery.Where(x => x.OfferUser.Username.ToLower()
                .Contains(search.Username) || x.ReceiverUser.Username.ToLower().Contains(search.Username));
            }

            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                filteredQuery = filteredQuery.Where(x => x.OfferUser.Email.ToLower()
                .Contains(search.Email) || x.ReceiverUser.Email.ToLower().Contains(search.Email));
            }

            if (!string.IsNullOrWhiteSpace(search?.Title)) 
            {
                filteredQuery = filteredQuery.Where(x => x.OfferBook.Title.ToLower()
                .Contains(search.Title) || x.ReceiverBook.Title.ToLower().Contains(search.Title));
            }

            if(search?.BookExchangeStatus != null)
            {
                filteredQuery = filteredQuery.Where(x => x.BookExchangeStatus == search.BookExchangeStatus);
            }

            if (search?.OfferUserId != null)
            {
                filteredQuery = filteredQuery.Where(x => x.OfferUserId == search.OfferUserId);
            }

            if (search?.ReceiverUserId != null)
            {
                filteredQuery = filteredQuery.Where(x => x.ReceiverUserId == search.ReceiverUserId);
            }

            return filteredQuery;
        }

        public override Task BeforeUpdate(BookExchange entity, BookExchangeUpdateDto update)
        {
            var offerAction = update.OfferUserAction ?? entity.OfferUserAction;
            var receiverAction = update.ReceiverUserAction ?? entity.ReceiverUserAction;

            if (entity.BookExchangeStatus == BookExchangeStatus.PendingApproval && receiverAction == true)
            {
                update.OfferUserAction = false;
                update.ReceiverUserAction = false;
                update.BookExchangeStatus = BookExchangeStatus.BookDeliveryPhase;
            }


            if (offerAction == true && receiverAction == true && entity.BookExchangeStatus == BookExchangeStatus.BookDeliveryPhase)
            {
                update.OfferUserAction = false;
                update.ReceiverUserAction = false;
                update.BookExchangeStatus = BookExchangeStatus.BookReceivingPhase;
            }

            return Task.CompletedTask;
        }


    }
}
