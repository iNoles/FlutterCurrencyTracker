import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'currency_model.dart';

class CurrencyService {
  final String baseUrl =
      "api.exchangerate.host"; // Used correctly for Uri.https()
  final String apiKey;
  final http.Client client;

  CurrencyService({http.Client? client, String? apiKey})
    : apiKey = apiKey ?? dotenv.env['API_KEY'] ?? '',
      client = client ?? http.Client() {
    if (this.apiKey.isEmpty) {
      throw Exception(
        'API key is missing. Make sure it is defined in the .env file.',
      );
    }
  }

  // Fetch live exchange rates
  Future<ExchangeRates> fetchExchangeRates(String baseCurrency) async {
    final uri = Uri.https(baseUrl, "/live", {
      "access_key": apiKey,
      "source": baseCurrency,
    });

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["success"] == true) {
        return ExchangeRates.fromJson(data);
      }
    }

    throw Exception('Invalid API response format: ${response.body}');
  }

  // Fetch historical exchange rates for a specific date
  Future<Map<String, dynamic>> fetchHistoricalRates(
    String date,
    String baseCurrency,
  ) async {
    final uri = Uri.https(baseUrl, '/historical', {
      'access_key': apiKey,
      'date': date, // Required date parameter
      'source': baseCurrency, // Optional: Base currency (default: USD)
    });

    final response = await client.get(uri);
    return _processJsonResponse(response);
  }

  // Convert one currency to another
  Future<double> convertCurrency(
    String fromCurrency,
    String toCurrency,
    String amount,
  ) async {
    final uri = Uri.https(baseUrl, '/convert', {
      'access_key': apiKey,
      'from': fromCurrency,
      'to': toCurrency,
      'amount': amount,
    });

    final response = await client.get(uri);
    final data = _processJsonResponse(response);

    if (data.containsKey("result")) {
      return data["result"].toDouble();
    } else {
      throw Exception('Failed to convert currency');
    }
  }

  // Helper function to process generic JSON responses
  Map<String, dynamic> _processJsonResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["success"] == true) {
        return data;
      }
    }
    throw Exception('Failed to load data: ${response.body}');
  }
}
