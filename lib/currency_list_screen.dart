import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'currency_model.dart';
import 'currency_service.dart';
import 'currency_chart_screen.dart';
import 'currency_converter_screen.dart';

class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen({super.key});

  @override
  CurrencyListScreenState createState() => CurrencyListScreenState();
}

class CurrencyListScreenState extends State<CurrencyListScreen> {
  final CurrencyService currencyService = CurrencyService();
  String baseCurrency = "USD"; // Default base currency

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rates'),
        actions: [
          DropdownButton<String>(
            value: baseCurrency,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  baseCurrency = newValue;
                });
              }
            },
            items: ["USD", "EUR", "GBP", "JPY", "AUD"]
                .map((String currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                .toList(),
          ),
        ],
      ),
      body: FutureBuilder<ExchangeRates>(
        future: currencyService.fetchExchangeRates(baseCurrency),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: ${snapshot.error}"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData) {
            Map<String, double>? quotes = snapshot.data?.quotes;
            if (quotes != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[200],
                    width: double.infinity,
                    child: Text(
                      "1 $baseCurrency =",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Expanded ListView
                  Expanded(
                    child: ListView.builder(
                      itemCount: quotes.length,
                      itemBuilder: (context, index) {
                        String currencyPair = quotes.keys.elementAt(index);
                        double rate = quotes[currencyPair] ?? 0.0;

                        // Extract target currency (e.g., "AED" from "USDAED")
                        String targetCurrency =
                            currencyPair.replaceFirst(snapshot.data!.sourceCurrency, "");

                        return _CurrencyListTile(
                          currency: targetCurrency,
                          rate: rate,
                          baseCurrency: snapshot.data!.sourceCurrency,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          }
          return const Center(child: Text("No data available"));
        },
      ),
    );
  }
}

class _CurrencyListTile extends StatelessWidget {
  final String currency;
  final double rate;
  final String baseCurrency;

  const _CurrencyListTile({
    required this.currency,
    required this.rate,
    required this.baseCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final formattedRate = NumberFormat.currency(
      locale: "en_US",
      symbol: "",
    ).format(rate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          currency,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          formattedRate,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => _CurrencyActions(
              baseCurrency: baseCurrency,
              targetCurrency: currency,
            ),
          );
        },
      ),
    );
  }
}

// Bottom Sheet for Chart & Conversion Actions
class _CurrencyActions extends StatelessWidget {
  final String baseCurrency;
  final String targetCurrency;

  const _CurrencyActions({
    required this.baseCurrency,
    required this.targetCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 150,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.show_chart, color: Colors.blue),
            title: const Text("View Chart"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CurrencyChartScreen(
                    baseCurrency: baseCurrency,
                    targetCurrency: targetCurrency,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: Colors.green),
            title: const Text("Convert Currency"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CurrencyConverterScreen(
                    fromCurrency: baseCurrency,
                    toCurrency: targetCurrency,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
