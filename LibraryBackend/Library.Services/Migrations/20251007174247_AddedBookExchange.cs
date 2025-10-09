using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Library.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddedBookExchange : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BookExchanges",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OfferUserId = table.Column<int>(type: "int", nullable: false),
                    ReceiverUserId = table.Column<int>(type: "int", nullable: false),
                    OfferBookId = table.Column<int>(type: "int", nullable: false),
                    ReceiverBookId = table.Column<int>(type: "int", nullable: false),
                    OfferUserAction = table.Column<bool>(type: "bit", nullable: false),
                    ReceiverUserAction = table.Column<bool>(type: "bit", nullable: false),
                    BookExchangeStatus = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BookExchanges", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BookExchanges_Books_OfferBookId",
                        column: x => x.OfferBookId,
                        principalTable: "Books",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_BookExchanges_Books_ReceiverBookId",
                        column: x => x.ReceiverBookId,
                        principalTable: "Books",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_BookExchanges_Users_OfferUserId",
                        column: x => x.OfferUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_BookExchanges_Users_ReceiverUserId",
                        column: x => x.ReceiverUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_BookExchanges_OfferBookId",
                table: "BookExchanges",
                column: "OfferBookId");

            migrationBuilder.CreateIndex(
                name: "IX_BookExchanges_OfferUserId",
                table: "BookExchanges",
                column: "OfferUserId");

            migrationBuilder.CreateIndex(
                name: "IX_BookExchanges_ReceiverBookId",
                table: "BookExchanges",
                column: "ReceiverBookId");

            migrationBuilder.CreateIndex(
                name: "IX_BookExchanges_ReceiverUserId",
                table: "BookExchanges",
                column: "ReceiverUserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BookExchanges");
        }
    }
}
