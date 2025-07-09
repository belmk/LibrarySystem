using AutoMapper;
using Library.Models.Base;
using Library.Services.Database;
using Library.Services.Interfaces.Base;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.BaseServices
{
    public abstract class BaseService<TModel, TSearch, TEntity> : IService<TModel, TSearch>
        where TSearch : BaseSearchObject
        where TEntity : class
    {
        protected readonly LibraryDbContext _context;
        protected readonly IMapper _mapper;

        protected BaseService(LibraryDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        protected virtual IQueryable<TEntity> AddInclude(IQueryable<TEntity> query)
        {
            return query;
        }

        public virtual async Task<PagedResult<TModel>> GetAsync(TSearch search)
        {
            IQueryable<TEntity> query = _context.Set<TEntity>().AsNoTracking();

            query = AddInclude(query);

            query = ApplyFilter(query, search);
            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }
            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                    query = query.Skip(search.Page.Value * search.PageSize ?? 10);
                if (search.PageSize.HasValue)
                    query = query.Take(search.PageSize.Value);
            }
            var list = await query.ToListAsync();
            var mappedList = _mapper.Map<List<TModel>>(list);
            return new PagedResult<TModel> { Items = mappedList, TotalCount = totalCount };
        }

        public virtual async Task<TModel?> GetByIdAsync(int id)
        {
            IQueryable<TEntity> query = _context.Set<TEntity>().AsNoTracking(); // Add AsNoTracking()
            query = AddInclude(query);
            var entity = await query.FirstOrDefaultAsync(e => EF.Property<int>(e, "Id") == id);
            return entity == null ? default : _mapper.Map<TModel>(entity);
        }

        protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search)
        {
            return query;
        }
    }
}
