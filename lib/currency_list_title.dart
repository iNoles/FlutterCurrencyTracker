import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'currency_actions.dart';

class CurrencyListTile extends StatelessWidget {
  final String currency;
  final double rate;
  final String baseCurrency;

  const CurrencyListTile({
    super.key,
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
            builder: (context) => CurrencyActions(
              baseCurrency: baseCurrency,
              targetCurrency: currency,
            ),
          );
        },
      ),
    );
  }
}
