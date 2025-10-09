using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Models.DTOs.DashboardData
{
    public class RatingStatsDto
    {
        public string Name { get; set; }
        public double AvgRating { get; set; }
        public int TotalRatings { get; set; }
    }
}
