using AutoMapper;
using Library.Models.Base;
using Library.Services.Database;
using Library.Services.Interfaces.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.BaseServices
{
    public abstract class BaseCRUDService<TModel, TSearch, TEntity, TCreateUpdate> :
        BaseService<TModel, TSearch, TEntity>, ICRUDService<TModel, TSearch, TCreateUpdate> where TSearch : BaseSearchObject where TEntity : class, new()
    {
        protected BaseCRUDService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public virtual async Task<TModel> InsertAsync(TCreateUpdate request)
        {
            var entity = _mapper.Map<TEntity>(request);
            _context.Set<TEntity>().Add(entity);
            await _context.SaveChangesAsync();
            return _mapper.Map<TModel>(entity);
        }

        public virtual async Task<TModel?> UpdateAsync(int id, TCreateUpdate request)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return default;
            _mapper.Map(request, entity);
            await _context.SaveChangesAsync();
            return _mapper.Map<TModel>(entity);
        }

        public virtual async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return false;
            _context.Set<TEntity>().Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
    }
