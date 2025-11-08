import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'book_loan_status.dart';

part 'book_loan.g.dart';

@JsonSerializable()
class BookLoan {
  int? id;
  User? user;
  Book? book;

  DateTime? loanDate;
  DateTime? returnDate;

  BookLoanStatus? loanStatus;

  BookLoan({
    this.id,
    this.user,
    this.book,
    this.loanDate,
    this.returnDate,
    this.loanStatus,
  });

  factory BookLoan.fromJson(Map<String, dynamic> json) =>
      _$BookLoanFromJson(json);

  Map<String, dynamic> toJson() => _$BookLoanToJson(this);
}
