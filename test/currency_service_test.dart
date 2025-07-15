import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:currency_tracker/currency_service.dart';

void main() {
  group('CurrencyService', () {
    test('fetchExchangeRates returns ExchangeRates on success', () async {
      final mockResponse = {
        "success": true,
        "source": "USD",
        "quotes": {"USDEUR": 0.9, "USDGBP": 0.8},
      };

      final mockClient = MockClient((request) async {
        expect(request.url.path, '/live');
        expect(request.url.queryParameters['source'], 'USD');

        return http.Response(json.encode(mockResponse), 200);
      });

      final service = CurrencyService(client: mockClient, apiKey: "TEST_KEY");
      final result = await service.fetchExchangeRates("USD");

      expect(result.sourceCurrency, "USD");
      expect(result.quotes["USDEUR"], 0.9);
      expect(result.quotes["USDGBP"], 0.8);
    });

    test('fetchHistoricalRates returns data on success', () async {
      final mockResponse = {
        "success": true,
        "historical": true,
        "date": "2023-01-01",
        "source": "USD",
        "quotes": {"USDEUR": 0.88},
      };

      final mockClient = MockClient((request) async {
        expect(request.url.path, '/historical');
        expect(request.url.queryParameters['date'], '2023-01-01');
        expect(request.url.queryParameters['source'], 'USD');

        return http.Response(json.encode(mockResponse), 200);
      });

      final service = CurrencyService(client: mockClient, apiKey: "TEST_KEY");
      final result = await service.fetchHistoricalRates("2023-01-01", "USD");

      expect(result["quotes"]["USDEUR"], 0.88);
    });

    test('convertCurrency returns converted amount on success', () async {
      final mockResponse = {
        "success": true,
        "query": {"from": "USD", "to": "EUR", "amount": 100},
        "result": 90.0,
      };

      final mockClient = MockClient((request) async {
        expect(request.url.path, '/convert');
        expect(request.url.queryParameters['from'], 'USD');
        expect(request.url.queryParameters['to'], 'EUR');
        expect(request.url.queryParameters['amount'], '100');

        return http.Response(json.encode(mockResponse), 200);
      });

      final service = CurrencyService(client: mockClient, apiKey: "TEST_KEY");
      final result = await service.convertCurrency("USD", "EUR", "100");

      expect(result, 90.0);
    });
  });

  test('fetchExchangeRates throws on non-200 response', () async {
    final mockClient = MockClient((_) async => http.Response('Error', 500));
    final service = CurrencyService(client: mockClient, apiKey: 'TEST_KEY');

    expect(() => service.fetchExchangeRates('USD'), throwsException);
  });

  test('fetchHistoricalRates throws on failure response', () async {
    final mockClient = MockClient((_) async => http.Response('Error', 400));
    final service = CurrencyService(client: mockClient, apiKey: 'TEST_KEY');

    expect(
      () => service.fetchHistoricalRates('2023-01-01', 'USD'),
      throwsException,
    );
  });

  test('convertCurrency throws when result missing', () async {
    final mockClient = MockClient(
      (_) async => http.Response(
        json.encode({
          "success": true,
          // no "result" field here
        }),
        200,
      ),
    );

    final service = CurrencyService(client: mockClient, apiKey: 'TEST_KEY');

    expect(() => service.convertCurrency('USD', 'EUR', '100'), throwsException);
  });

  test('throws exception if API key is missing', () {
    // You can pass empty string explicitly
    expect(
      () => CurrencyService(
        client: MockClient((_) async => http.Response('', 200)),
        apiKey: '',
      ),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('API key is missing'),
        ),
      ),
    );
  });
}
