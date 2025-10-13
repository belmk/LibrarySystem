import 'package:flutter/material.dart';
import 'package:elibrary_desktop/providers/dashboard_provider.dart';
import 'package:elibrary_desktop/models/dashboard_models/book_loan_stats_dto.dart';
import 'package:elibrary_desktop/models/dashboard_models/user_loan_stats_dto.dart';
import 'package:elibrary_desktop/models/dashboard_models/rating_stats_dto.dart';
import 'package:elibrary_desktop/models/dashboard_models/monthly_revenue_dto.dart';
import 'package:fl_chart/fl_chart.dart';

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
                  title: 'Top $_topX Borrowed Books',
                  future: _provider.getTopBorrowedBooks(_topX),
                  dropdownValue: _topX,
                  onChanged: (val) => setState(() => _topX = val),
                  columns: const ['Book', 'Borrows'],
                  rowBuilder: (e) => [e.title, e.loanCount.toString()],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTopCard<UserLoanStatsDto>(
                  title: 'Top $_topX Active Users',
                  future: _provider.getTopActiveUsers(_topX),
                  dropdownValue: _topX,
                  onChanged: (val) => setState(() => _topX = val),
                  columns: const ['User', 'Borrows'],
                  rowBuilder: (e) => [e.username, e.loanCount.toString()],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTopCard<RatingStatsDto>(
                  title: 'Top $_topX Rated Books',
                  future: _provider.getTopRatedBooks(_topX),
                  dropdownValue: _topX,
                  onChanged: (val) => setState(() => _topX = val),
                  columns: const ['Book', 'Rating'],
                  rowBuilder: (e) => ['${e.name} (${e.totalRatings})', e.avgRating.toStringAsFixed(2)],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTopCard<RatingStatsDto>(
                  title: 'Top $_topX Rated Users',
                  future: _provider.getTopRatedUsers(_topX),
                  dropdownValue: _topX,
                  onChanged: (val) => setState(() => _topX = val),
                  columns: const ['User', 'Rating'],
                  rowBuilder: (e) => ['${e.name} (${e.totalRatings})', e.avgRating.toStringAsFixed(2)],
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
                title: 'Borrows in Last $_lastXMonths Months',
                future: _provider.getBorrowStats(_lastXMonths),
                onChanged: (val) => setState(() => _lastXMonths = val),
              ),
              _buildChartCard(
                title: 'Profit in Last $_lastXMonths Months',
                future: _provider.getProfitStats(_lastXMonths),
                onChanged: (val) => setState(() => _lastXMonths = val),
              ),
            ],
          ),
        ],
      ),
    ),
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
                  Text(title,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No data"));
                    }

                    final data = snapshot.data!;
                    final spots = data.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
                    }).toList();

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
                          )
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, _) {
                                if (value < 0 || value >= data.length) return const Text('');
                                return Text(data[value.toInt()].month);
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
