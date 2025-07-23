using AutoMapper;
using Library.Models.DTOs.Roles;
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
    public class RoleService : BaseCRUDService<RoleDto, Role, RoleSearchObject, RoleInsertDto, RoleUpdateDto>, IRoleService
    {
        public RoleService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Role> AddFilter(IQueryable<Role> query, RoleSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Name))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.Name));
            }

            return filteredQuery;
        }
    }
}
