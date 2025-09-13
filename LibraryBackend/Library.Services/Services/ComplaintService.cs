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

            if (!String.IsNullOrEmpty(search?.Username))
            {
                filteredQuery = filteredQuery.Where(x => x.Sender.Username.Contains(search.Username));
            }

            if (!String.IsNullOrEmpty(search?.Email))
            {
                filteredQuery = filteredQuery.Where(x => x.Sender.Email.Contains(search.Email));
            }

            if (search?.ComplaintDate != null && search.ComplaintDate != DateTime.MinValue)
            {
                filteredQuery = filteredQuery.Where(x => x.ComplaintDate.Date.Equals(search.ComplaintDate.Value.Date));
            }


            return filteredQuery;
        }
    }
}
