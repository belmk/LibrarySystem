using Library.Models.DTOs.Books;
using Library.Services.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces
{
    public interface IRecommenderService
    {
        Task<IReadOnlyList<BookDto>> RecommendAsync(
           int userId,
           int take = 10,
           CancellationToken ct = default);
    }
}
