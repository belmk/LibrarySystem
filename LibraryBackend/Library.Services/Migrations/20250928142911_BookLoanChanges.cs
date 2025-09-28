using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Library.Services.Migrations
{
    /// <inheritdoc />
    public partial class BookLoanChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsApproved",
                table: "BookLoans");

            migrationBuilder.AddColumn<int>(
                name: "LoanStatus",
                table: "BookLoans",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LoanStatus",
                table: "BookLoans");

            migrationBuilder.AddColumn<bool>(
                name: "IsApproved",
                table: "BookLoans",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }
    }
}
