import 'package:currency_tracker/currency_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization
  await dotenv.load(fileName: ".env");
  runApp(const CurrencyChartApp());
}

class CurrencyChartApp extends StatelessWidget {
  const CurrencyChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CurrencyListScreen()
    );
  }
}
