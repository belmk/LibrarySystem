import 'package:flutter/material.dart';
import 'package:elibrary_desktop/models/book_loan.dart';
import 'package:elibrary_desktop/providers/book_loan_provider.dart';
import 'package:elibrary_desktop/utils/datetime_helper.dart';

class BookLoanHistoryScreen extends StatefulWidget {
  final int userId;
  final String username;

  const BookLoanHistoryScreen({super.key, required this.userId, required this.username});

  @override
  State<BookLoanHistoryScreen> createState() => _BookLoanHistoryScreenState();
}

class _BookLoanHistoryScreenState extends State<BookLoanHistoryScreen> {
  final BookLoanProvider _bookLoanProvider = BookLoanProvider();

  List<BookLoan> _loanHistory = [];
  bool _isLoading = true;
  String? _error;

  int _currentPage = 1;
  final int _pageSize = 5;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadLoanHistory();
  }

  Future<void> _loadLoanHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _bookLoanProvider.get(filter: {
        "UserId": widget.userId,
        "Page": _currentPage - 1,
        "PageSize": _pageSize,
      });

      setState(() {
        _loanHistory = result.result;
        _totalCount = result.count ?? 0;

        if (_currentPage > _totalPages) {
          _currentPage = _totalPages;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Greška prilikom učitavanja historije: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Widget _buildTable() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_loanHistory.isEmpty) {
      return const Center(child: Text("Nema dostupne historije pozajmica."));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Naziv knjige")),
          DataColumn(label: Text("Datum pozajmice")),
          DataColumn(label: Text("Datum vraćanja")),
        ],
        rows: _loanHistory.map((loan) {
          return DataRow(
            cells: [
              DataCell(Text(loan.book?.title ?? "-")),
              DataCell(Text(DateTimeHelper.formatDateTime(loan.loanDate))),
              DataCell(Text(DateTimeHelper.formatDateTime(loan.returnDate))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                  _loadLoanHistory();
                }
              : null,
          icon: const Icon(Icons.arrow_back),
        ),
        Text("Stranica $_currentPage od $_totalPages"),
        IconButton(
          onPressed: _currentPage < _totalPages
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                  _loadLoanHistory();
                }
              : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.username),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          children: [
            Expanded(child: _buildTable()),
            const SizedBox(height: 12),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }
}
