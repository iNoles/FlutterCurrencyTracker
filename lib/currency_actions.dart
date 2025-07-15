import 'package:flutter/material.dart';

import 'currency_chart_screen.dart';
import 'currency_converter_screen.dart';

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
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        // Use mainAxisSize.min so height fits content dynamically
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row with drag handle and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Close button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),

            // Action: View Chart
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

            // Action: Convert Currency
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
      ),
    );
  }
}
