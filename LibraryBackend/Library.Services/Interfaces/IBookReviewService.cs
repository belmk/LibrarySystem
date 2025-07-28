using Library.Models.DTOs.BookReviews;
using Library.Models.SearchObjects;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IBookReviewService : ICRUDService<BookReviewDto, BookReviewSearchObject, BookReviewInsertDto, BookReviewUpdateDto>
    {
    }
}
