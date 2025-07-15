import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'currency_model.dart';
import 'currency_service.dart';

// Supported currencies
final supportedCurrenciesProvider = Provider<List<String>>(
  (ref) => ["USD", "EUR", "GBP", "JPY", "AUD"],
);

// Selected base currency
final baseCurrencyProvider = StateProvider<String>((ref) => "USD");

// Exchange rates for the selected base currency
final exchangeRatesProvider = FutureProvider<ExchangeRates>((ref) {
  final base = ref.watch(baseCurrencyProvider);
  return CurrencyService().fetchExchangeRates(base);
});
