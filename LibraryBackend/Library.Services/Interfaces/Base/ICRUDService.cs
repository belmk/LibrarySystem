using Library.Models.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Interfaces.Base
{
    public interface ICRUDService<TModel, TSearch, TCreateUpdate>
        : IService<TModel, TSearch>
        where TSearch : BaseSearchObject
    {
        Task<TModel> InsertAsync(TCreateUpdate request);
        Task<TModel?> UpdateAsync(int id, TCreateUpdate request);
        Task<bool> DeleteAsync(int id);
    }
}
