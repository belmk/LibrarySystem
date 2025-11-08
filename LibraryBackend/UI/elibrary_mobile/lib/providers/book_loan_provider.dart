import 'package:elibrary_mobile/models/book_loan.dart';
import 'package:elibrary_mobile/providers/base_provider.dart';

class BookLoanProvider extends BaseProvider<BookLoan> {
  BookLoanProvider() : super("BookLoan");

  @override
  BookLoan fromJson(data) => BookLoan.fromJson(data);
}