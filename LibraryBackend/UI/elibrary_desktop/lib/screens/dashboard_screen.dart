import 'package:flutter/material.dart';
import 'package:elibrary_desktop/providers/dashboard_provider.dart';
import 'package:elibrary_desktop/models/dashboard_models/book_loan_stats_dto.dart';
import 'package:elibrary_desktop/models/dashboard_models/user_loan_stats_dto.dart';
import 'package:elibrary_desktop/models/dashboard_models/rating_stats_dto.dart';
import 'package:elibrary_desktop/models/dashboard_models/monthly_revenue_dto.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardProvider _provider = DashboardProvider();

  int _topX = 5;
  int _lastXMonths = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTopCard<BookLoanStatsDto>(
                    title: 'Top $_topX najposuđenijih knjiga',
                    future: _provider.getTopBorrowedBooks(_topX),
                    dropdownValue: _topX,
                    onChanged: (val) => setState(() => _topX = val),
                    columns: const ['Knjiga', 'Posudbi'],
                    rowBuilder: (e) => [e.title, e.loanCount.toString()],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTopCard<UserLoanStatsDto>(
                    title: 'Top $_topX najaktivnijih korisnika',
                    future: _provider.getTopActiveUsers(_topX),
                    dropdownValue: _topX,
                    onChanged: (val) => setState(() => _topX = val),
                    columns: const ['Korisnik', 'Posudio knjiga'],
                    rowBuilder: (e) => [e.username, e.loanCount.toString()],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTopCard<RatingStatsDto>(
                    title: 'Top $_topX ocijenjenih knjiga',
                    future: _provider.getTopRatedBooks(_topX),
                    dropdownValue: _topX,
                    onChanged: (val) => setState(() => _topX = val),
                    columns: const ['Knjiga', 'Ocjena'],
                    rowBuilder: (e) =>
                        ['${e.name} (${e.totalRatings})', e.avgRating.toStringAsFixed(2)],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTopCard<RatingStatsDto>(
                    title: 'Top $_topX ocijenjenih korisnika',
                    future: _provider.getTopRatedUsers(_topX),
                    dropdownValue: _topX,
                    onChanged: (val) => setState(() => _topX = val),
                    columns: const ['Korisnik', 'Ocjena'],
                    rowBuilder: (e) =>
                        ['${e.name} (${e.totalRatings})', e.avgRating.toStringAsFixed(2)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildChartCard(
                  title: 'Posudbi u zadnjih $_lastXMonths mjeseci',
                  future: _provider.getBorrowStats(_lastXMonths),
                  onChanged: (val) => setState(() => _lastXMonths = val),
                ),
                _buildChartCard(
                  title: 'Zarade u zadnjih $_lastXMonths mjeseci',
                  future: _provider.getProfitStats(_lastXMonths),
                  onChanged: (val) => setState(() => _lastXMonths = val),
                ),
              ],
            ),
            Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generiši izvještaj'),
              onPressed: _generateReport,
            ),
          ),
          ],
        ),
      ),
    );
  }

Future<void> _generateReport() async {
  final topBooks = await _provider.getTopBorrowedBooks(_topX);
  final topUsers = await _provider.getTopActiveUsers(_topX);
  final topRatedBooks = await _provider.getTopRatedBooks(_topX);
  final topRatedUsers = await _provider.getTopRatedUsers(_topX);
  final borrowStats = await _provider.getBorrowStats(_lastXMonths);
  final profitStats = await _provider.getProfitStats(_lastXMonths);

  final pdf = pw.Document();

  final tableHeaderStyle = pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: 12,
  );

  final tableCellStyle = pw.TextStyle(
    fontSize: 11,
  );

  final now = DateTime.now();
  final keyFormatter = DateFormat('MM/yyyy');
  final labelFormatter = DateFormat('MMM');

  final Map<String, int> loanMap = {
    for (var e in borrowStats) e.month: e.count
  };

  final filledLoanData = List.generate(_lastXMonths, (i) {
    final date = DateTime(now.year, now.month - (_lastXMonths - 1 - i));
    final monthKey = keyFormatter.format(date);
    final monthLabel = labelFormatter.format(date);

    return [monthLabel, (loanMap[monthKey] ?? 0).toString()];
  });

  final Map<String, int> profitMap = {
    for (var e in profitStats) e.month: e.count
  };

  final filledProfitData = List.generate(_lastXMonths, (i) {
    final date = DateTime(now.year, now.month - (_lastXMonths - 1 - i));
    final monthKey = keyFormatter.format(date);
    final monthLabel = labelFormatter.format(date);

    return [monthLabel, (profitMap[monthKey] ?? 0).toString()];
  });

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (context) => [
        pw.Center(
          child: pw.Text(
            'Izvjestaj Dashboarda',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Datum: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
        pw.Divider(height: 20, thickness: 2),

        pw.Text('Top $_topX najposudjenijih knjiga',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        _buildTable(
          headers: ['Knjiga', 'Posudbi'],
          data: topBooks.map((e) => [e.title, e.loanCount.toString()]).toList(),
          headerStyle: tableHeaderStyle,
          cellStyle: tableCellStyle,
        ),
        pw.SizedBox(height: 15),

        pw.Text('Top $_topX najaktivnijih korisnika',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        _buildTable(
          headers: ['Korisnik', 'Posudio knjiga'],
          data: topUsers.map((e) => [e.username, e.loanCount.toString()]).toList(),
          headerStyle: tableHeaderStyle,
          cellStyle: tableCellStyle,
        ),
        pw.SizedBox(height: 15),

        pw.Text('Top $_topX ocijenjenih knjiga',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        _buildTable(
          headers: ['Knjiga', 'Ocjena (broj ocjena)'],
          data: topRatedBooks
              .map(
                (e) => ['${e.name} (${e.totalRatings})', e.avgRating.toStringAsFixed(2)],
              )
              .toList(),
          headerStyle: tableHeaderStyle,
          cellStyle: tableCellStyle,
        ),
        pw.SizedBox(height: 15),

        pw.Text('Top $_topX ocijenjenih korisnika',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        _buildTable(
          headers: ['Korisnik', 'Ocjena (broj ocjena)'],
          data: topRatedUsers
              .map(
                (e) => ['${e.name} (${e.totalRatings})', e.avgRating.toStringAsFixed(2)],
              )
              .toList(),
          headerStyle: tableHeaderStyle,
          cellStyle: tableCellStyle,
        ),

        pw.SizedBox(height: 15),
        pw.Text('Broj posudbi u zadnjih $_lastXMonths mjeseci',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        _buildTable(
          headers: ['Mjesec', 'Posudbi'],
          data: filledLoanData, 
          headerStyle: tableHeaderStyle,
          cellStyle: tableCellStyle,
        ),

       
        pw.SizedBox(height: 15),
        pw.Text('Zarade u zadnjih $_lastXMonths mjeseci',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        _buildTable(
          headers: ['Mjesec', 'Zarada'],
          data: filledProfitData,
          headerStyle: tableHeaderStyle,
          cellStyle: tableCellStyle,
        ),
      ],
    ),
  );

  final pdfBytes = await pdf.save();
  await Printing.sharePdf(
    bytes: pdfBytes,
    filename: 'Dashboard_Izvjestaj_${DateTime.now().year}_${DateTime.now().month}.pdf',
  );
}


pw.Widget _buildTable({
  required List<String> headers,
  required List<List<String>> data,
  required pw.TextStyle headerStyle,
  required pw.TextStyle cellStyle,
}) {
  return pw.Table.fromTextArray(
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
    headerHeight: 25,
    cellHeight: 22,
    headerStyle: headerStyle,
    cellStyle: cellStyle,
    headers: headers,
    data: data,
    cellAlignments: {for (var i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft},
  );
}




  Widget _buildTopCard<T>({
    required String title,
    required Future<List<T>> future,
    required int dropdownValue,
    required Function(int) onChanged,
    required List<String> columns,
    required List<String> Function(T) rowBuilder,
  }) {
    final verticalController = ScrollController();
    return SizedBox(
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownButton<int>(
                    value: dropdownValue,
                    items: [3, 5, 10, 15]
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) onChanged(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<T>>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No data found"));
                    }
                    return Scrollbar(
                      controller: verticalController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: verticalController,
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 12,
                            columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
                            rows: snapshot.data!
                                .map((e) => DataRow(
                                      cells: rowBuilder(e)
                                          .map((val) => DataCell(Text(val, softWrap: true)))
                                          .toList(),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required Future<List<MonthlyRevenueDto>> future,
    required Function(int) onChanged,
  }) {
    return SizedBox(
      width: 600,
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    value: _lastXMonths,
                    items: [3, 6, 12]
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) onChanged(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<MonthlyRevenueDto>>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: Text("No data"));
                    }

                    final now = DateTime.now();
                    final keyFormatter = DateFormat('MM/yyyy');
                    final labelFormatter = DateFormat('MMM');

                    final Map<String, int> dataMap = {
                      for (var e in snapshot.data!) e.month: e.count
                    };

                    final filledData = List.generate(_lastXMonths, (i) {
                      final date = DateTime(now.year, now.month - (_lastXMonths - 1 - i));
                      final monthKey = keyFormatter.format(date);
                      final displayLabel = labelFormatter.format(date); 

                      return MonthlyRevenueDto(
                        month: displayLabel,
                        count: dataMap[monthKey] ?? 0,
                      );
                    });

                    final spots = filledData
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.count.toDouble(),
                            ))
                        .toList();

                    return LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 2,
                            color: Colors.blue,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, _) {
                                if (value < 0 || value >= filledData.length) {
                                  return const Text('');
                                }
                                return Text(filledData[value.toInt()].month);
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
