import 'package:elibrary_desktop/models/book_loan.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class BookLoanProvider extends BaseProvider<BookLoan> {
  BookLoanProvider() : super("BookLoan");

  @override
  BookLoan fromJson(data) => BookLoan.fromJson(data);
}