import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'currency_list_title.dart';
import 'providers.dart';

class CurrencyListScreen extends ConsumerWidget {
  const CurrencyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportedCurrencies = ref.watch(supportedCurrenciesProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);
    final exchangeRatesAsync = ref.watch(exchangeRatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rates'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: baseCurrency,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: Colors.blue[50],
                onChanged: (newValue) {
                  if (newValue != null) {
                    ref.read(baseCurrencyProvider.notifier).state = newValue;
                  }
                },
                items: supportedCurrencies
                    .map(
                      (currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency, semanticsLabel: 'Base $currency'),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      body: exchangeRatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: $err", style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(exchangeRatesProvider),
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
        data: (exchangeRates) => RefreshIndicator(
          onRefresh: () async => ref.refresh(exchangeRatesProvider),
          child: CurrencyRatesList(
            quotes: exchangeRates.quotes,
            baseCurrency: exchangeRates.sourceCurrency,
            lastUpdated: DateTime.fromMillisecondsSinceEpoch(
              exchangeRates.timestamp * 1000,
            ),
          ),
        ),
      ),
    );
  }
}

class CurrencyRatesList extends StatelessWidget {
  final Map<String, double> quotes;
  final String baseCurrency;
  final DateTime lastUpdated;

  const CurrencyRatesList({
    super.key,
    required this.quotes,
    required this.baseCurrency,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final rates = quotes.entries.toList();
    if (rates.isEmpty) {
      return Center(
        child: Text(
          'No exchange rates available.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final lastUpdatedFormatted = DateFormat.yMMMd().add_jm().format(
      lastUpdated,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[200],
          width: double.infinity,
          child: Text(
            "1 $baseCurrency =",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Add Last Updated display here, above the list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.update, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Last Updated: $lastUpdatedFormatted',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: rates.length,
            itemBuilder: (context, index) {
              final entry = rates[index];
              final targetCurrency = entry.key.startsWith(baseCurrency)
                  ? entry.key.substring(baseCurrency.length)
                  : entry.key;
              return CurrencyListTile(
                currency: targetCurrency,
                rate: entry.value,
                baseCurrency: baseCurrency,
              );
            },
          ),
        ),
      ],
    );
  }
}
