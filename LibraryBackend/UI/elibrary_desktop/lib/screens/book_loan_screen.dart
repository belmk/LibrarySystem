import 'package:flutter/material.dart';
import 'package:elibrary_desktop/models/book_loan.dart';
import 'package:elibrary_desktop/models/book_loan_status.dart';
import 'package:elibrary_desktop/providers/book_loan_provider.dart';
import 'package:elibrary_desktop/utils/datetime_helper.dart';

class BookLoanScreen extends StatefulWidget {
  const BookLoanScreen({super.key});

  @override
  State<BookLoanScreen> createState() => _BookLoanScreenState();
}

class _BookLoanScreenState extends State<BookLoanScreen> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _loanDateController = TextEditingController();
  DateTime? _selectedLoanDate;

  final BookLoanProvider _bookLoanProvider = BookLoanProvider();

  List<BookLoan> _bookLoans = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _pageSize = 8;
  int _totalCount = 0;

  BookLoanStatus? _selectedStatus;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadBookLoans();
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _usernameController.dispose();
    _loanDateController.dispose();
    super.dispose();
  }

  Future<void> _loadBookLoans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _bookLoanProvider.get(
        filter: {
          "BookName": _bookNameController.text.trim(),
          "Username": _usernameController.text.trim(),
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
          if (_selectedStatus != null) "LoanStatus": _selectedStatus!.index,
          if (_selectedLoanDate != null)
            "LoanDate": _selectedLoanDate!.toIso8601String(),
        },
      );

      setState(() {
        _bookLoans = result.result;
        _totalCount = result.count ?? 0;

        if (_currentPage > _totalPages) {
          _currentPage = _totalPages;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Greška pri učitavanju pozajmica: ${e.toString()}";
      });
    }
  }

  void _onSearchPressed() {
    _currentPage = 1;
    _loadBookLoans();
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _bookNameController,
              decoration: const InputDecoration(labelText: 'Naziv knjige'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Korisničko ime'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<BookLoanStatus>(
              value: _selectedStatus,
              items: BookLoanStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Status pozajmice'),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),

          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _loanDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Datum pozajmice',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedLoanDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    _selectedLoanDate = picked;
                    _loanDateController.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pretraži',
            onPressed: _onSearchPressed,
          ),
        ],
      ),
    );
  }

 Widget _buildLoanCard(BookLoan loan) {
  final statusColor = loan.loanStatus?.color ?? Colors.grey;

  String formatDate(DateTime? date) {
    return date != null ? DateTimeHelper.formatDateTime(date) : '-';
  }

  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colored status strip
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username as title (no label)
              Text(
                loan.user?.username ?? '-',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Info rows
              _buildInfoRow('Naziv knjige', loan.book?.title ?? '-'),
              _buildInfoRow(
                'Autor',
                loan.book?.author != null
                    ? '${loan.book!.author!.firstName ?? ''} ${loan.book!.author!.lastName ?? ''}'.trim()
                    : '-',
              ),
              _buildInfoRow('Status', loan.loanStatus?.displayName ?? '-'),
              _buildInfoRow('Datum pozajmice', formatDate(loan.loanDate)),
              _buildInfoRow('Datum vraćanja', formatDate(loan.returnDate)),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}



  Widget _buildLoanGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(builder: (context, constraints) {
        const itemsPerRow = 4;
        final rows = <Widget>[];

        for (int i = 0; i < _bookLoans.length; i += itemsPerRow) {
  final rowItems = _bookLoans
      .skip(i)
      .take(itemsPerRow)
      .map((loan) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildLoanCard(loan),
            ),
          ))
      .toList();

  while (rowItems.length < itemsPerRow) {
    rowItems.add(const Expanded(child: SizedBox()));
  }

  rows.add(Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: rowItems,
  ));
}


        return Column(children: rows);
      }),
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
                  _loadBookLoans();
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
                  _loadBookLoans();
                }
              : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildLoanGrid()),
          _buildPaginationControls(),
        ],
      ),
    );
  }
}
