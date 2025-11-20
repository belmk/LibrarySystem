using Library.Models.DTOs.UserReviews;
using Library.Models.SearchObjects;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IUserReviewService : ICRUDService<UserReviewDto, UserReviewSearchObject, UserReviewInsertDto, UserReviewUpdateDto>
    {
    }
}
