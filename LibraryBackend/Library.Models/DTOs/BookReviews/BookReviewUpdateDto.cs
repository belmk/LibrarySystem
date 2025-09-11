﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.BookReviews
{
    public class BookReviewUpdateDto
    {
        public int Rating {  get; set; }
        public string Comment { get; set; }
        public bool IsApproved { get; set; }
        public bool IsDenied { get; set; }

    }
}
