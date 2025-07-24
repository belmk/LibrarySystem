using AutoMapper;
using Library.Models;
using Library.Models.DTOs.Authors;
using Library.Models.DTOs.Books;
using Library.Models.DTOs.Complaints;
using Library.Models.DTOs.Genres;
using Library.Models.DTOs.Roles;
using Library.Models.DTOs.Subscriptions;
using Library.Models.DTOs.Users;
using Library.Models.Entities;
using Library.Models.SearchObjects;
using Library.Services.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Services.Mappings
{
    public class MappingProfile : Profile
    {
        public MappingProfile() {

            CreateMap<Book, BookDto>()
                .ForMember(dest => dest.Genres, opt => opt.MapFrom(src => src.Genres));
            CreateMap<BookInsertDto, Book>();
            CreateMap<BookUpdateDto, Book>();


            CreateMap<Genre, GenreDto>();
            CreateMap<GenreInsertDto, Genre>();
            CreateMap<GenreUpdateDto, Genre>();


            CreateMap<Author, AuthorDto>();
            CreateMap<AuthorInsertDto, Author>();
            CreateMap<AuthorUpdateDto, Author>();


            CreateMap<Role, RoleDto>();
            CreateMap<RoleInsertDto, Role>();
            CreateMap<RoleUpdateDto, Role>();


            CreateMap<User, UserDto>();
            CreateMap<UserInsertDto, User>();
            CreateMap<UserUpdateDto, User>();
            CreateMap<UserSearchObject, User>();


            CreateMap<Subscription, SubscriptionDto>();
            CreateMap<SubscriptionInsertDto, Subscription>();
            CreateMap<SubscriptionUpdateDto, Subscription>();


            CreateMap<Complaint, ComplaintDto>();
            CreateMap<ComplaintInsertDto, Complaint>();
            CreateMap<ComplaintUpdateDto, Complaint>();


        }
    }
}
