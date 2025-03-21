class ExchangeRates {
  final String sourceCurrency;
  final Map<String, double> quotes;

  ExchangeRates({required this.sourceCurrency, required this.quotes});

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    return ExchangeRates(
      sourceCurrency: json["source"] ?? "USD",
      quotes: (json["quotes"] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value is int) ? value.toDouble() : value),
      ),
    );
  }
}
