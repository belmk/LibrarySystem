using AutoMapper;
using Library.Models.DTOs.Complaints;
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
    public class ComplaintService : BaseCRUDService<ComplaintDto, Complaint, ComplaintSearchObject, ComplaintInsertDto, ComplaintUpdateDto>, IComplaintService
    {
        public ComplaintService(LibraryDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Complaint> AddFilter(IQueryable<Complaint> query, ComplaintSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            filteredQuery = filteredQuery.Include(x => x.Sender).Include(x => x.Target);

            if (search.Target != null)
            {
                if(!String.IsNullOrWhiteSpace(search.Target.FirstName))
                    filteredQuery = filteredQuery.Where(x => x.Target.FirstName.Contains(search.Target.FirstName));

                if (!String.IsNullOrWhiteSpace(search.Target.LastName))
                    filteredQuery = filteredQuery.Where(x => x.Target.FirstName.Contains(search.Target.LastName));

                if (!String.IsNullOrWhiteSpace(search.Target.Username))
                    filteredQuery = filteredQuery.Where(x => x.Target.FirstName.Contains(search.Target.Username));

                if (!String.IsNullOrWhiteSpace(search.Target.Email))
                    filteredQuery = filteredQuery.Where(x => x.Target.FirstName.Contains(search.Target.Email));

                if (search.Target.IsActive.HasValue)
                    filteredQuery = filteredQuery.Where(x => x.Target.IsActive == search.Target.IsActive);
            }

            if (search.Sender != null)
            {
                if (!String.IsNullOrWhiteSpace(search.Sender.FirstName))
                    filteredQuery = filteredQuery.Where(x => x.Sender.FirstName.Contains(search.Sender.FirstName));

                if (!String.IsNullOrWhiteSpace(search.Sender.LastName))
                    filteredQuery = filteredQuery.Where(x => x.Sender.FirstName.Contains(search.Sender.LastName));

                if (!String.IsNullOrWhiteSpace(search.Sender.Username))
                    filteredQuery = filteredQuery.Where(x => x.Sender.FirstName.Contains(search.Sender.Username));

                if (!String.IsNullOrWhiteSpace(search.Sender.Email))
                    filteredQuery = filteredQuery.Where(x => x.Target.FirstName.Contains(search.Sender.Email));

                if (search.Sender.IsActive.HasValue)
                    filteredQuery = filteredQuery.Where(x => x.Sender.IsActive == search.Sender.IsActive);
            }
            

            return filteredQuery;
        }
    }
}
