using Library.Models.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces.Base
{
    public interface IService<T, TSearch> where TSearch : class
    {
        Task<PagedResult<T>> Get(TSearch search = null);
        Task<T> GetById(int id);
    }
}
