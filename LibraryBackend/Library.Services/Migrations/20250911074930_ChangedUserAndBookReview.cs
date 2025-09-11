using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Library.Services.Migrations
{
    /// <inheritdoc />
    public partial class ChangedUserAndBookReview : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "WarningNumber",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "IsDenied",
                table: "BookReviews",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "WarningNumber",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "IsDenied",
                table: "BookReviews");
        }
    }
}
