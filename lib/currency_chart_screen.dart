import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'currency_service.dart';
import 'package:intl/intl.dart';

class CurrencyChartScreen extends StatefulWidget {
  final String baseCurrency;
  final String targetCurrency;

  const CurrencyChartScreen({
    super.key,
    required this.baseCurrency,
    required this.targetCurrency,
  });

  @override
  CurrencyChartScreenState createState() => CurrencyChartScreenState();
}

class CurrencyChartScreenState extends State<CurrencyChartScreen> {
  final CurrencyService currencyService = CurrencyService();
  late Future<List<FlSpot>> historicalRatesFuture;

  @override
  void initState() {
    super.initState();
    historicalRatesFuture = fetchChartData();
  }

  List<String> getLastNDays(int n) {
    return List.generate(n, (index) {
      DateTime date = DateTime.now().subtract(Duration(days: index));
      return DateFormat("yyyy-MM-dd").format(date);
    }).reversed.toList();
  }

  Future<List<FlSpot>> fetchChartData() async {
    List<String> last10Days = getLastNDays(10);
    
    try {
      final futures = last10Days.map(
        (date) => currencyService.fetchHistoricalRates(date, widget.baseCurrency),
      );
      final results = await Future.wait(futures);

      List<FlSpot> chartData = [];
      for (int i = 0; i < results.length; i++) {
        final data = results[i];
        double rate = data["rates"]?[widget.targetCurrency] ?? 0;
        chartData.add(FlSpot(i.toDouble(), rate));
      }

      return chartData;
    } catch (e) {
      debugPrint("Error fetching historical rates: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.baseCurrency} to ${widget.targetCurrency}')),
      body: FutureBuilder<List<FlSpot>>(
        future: historicalRatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(child: _CurrencyChart(chartData: snapshot.data!)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CurrencyChart extends StatelessWidget {
  final List<FlSpot> chartData;

  const _CurrencyChart({required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < chartData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        DateFormat("MMM dd").format(
                          DateTime.now().subtract(Duration(days: chartData.length - 1 - index)),
                        ),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
