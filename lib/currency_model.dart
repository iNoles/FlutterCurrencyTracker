class ExchangeRates {
  final String sourceCurrency;
  final int timestamp;
  final Map<String, double> quotes;

  ExchangeRates({
    required this.sourceCurrency,
    required this.timestamp,
    required this.quotes,
  });

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    final quotesJson = json["quotes"] as Map<String, dynamic>? ?? {};

    return ExchangeRates(
      sourceCurrency: json["source"] ?? "USD",
      timestamp: json["timestamp"] ?? 0,
      quotes: quotesJson.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }
}
