import 'package:flutter/material.dart';

import 'currency_chart_screen.dart';
import 'currency_converter_screen.dart';

// Bottom Sheet for Chart & Conversion Actions
class CurrencyActions extends StatelessWidget {
  final String baseCurrency;
  final String targetCurrency;

  const CurrencyActions({
    super.key,
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
