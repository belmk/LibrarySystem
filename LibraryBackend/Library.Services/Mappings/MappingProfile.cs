using AutoMapper;
using Library.Models;
using Library.Models.DTOs.Authors;
using Library.Models.DTOs.Books;
using Library.Models.DTOs.Genres;
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
        }
    }
}
