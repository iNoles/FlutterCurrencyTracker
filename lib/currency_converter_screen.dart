import 'package:flutter/material.dart';
import 'currency_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  final String fromCurrency;
  final String toCurrency;

  const CurrencyConverterScreen({
    required this.fromCurrency,
    required this.toCurrency,
    super.key,
  });

  @override
  CurrencyConverterScreenState createState() => CurrencyConverterScreenState();
}

class CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final CurrencyService currencyService = CurrencyService();
  final TextEditingController amountController = TextEditingController();
  double? convertedAmount;
  bool isLoading = false;

  Future<void> convertCurrency() async {
  setState(() => isLoading = true);
  try {
    double result = await currencyService.convertCurrency(
      widget.fromCurrency,
      widget.toCurrency,
      amountController.text,
    );

    if (!mounted) return; // ✅ Prevent context-related issues

    setState(() {
      convertedAmount = result;
    });
  } catch (error) {
    if (!mounted) return; // ✅ Ensure widget is still active

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Convert ${widget.fromCurrency} → ${widget.toCurrency}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: convertCurrency,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Convert"),
            ),
            const SizedBox(height: 20),
            if (convertedAmount != null)
              Text(
                "Converted Amount: ${convertedAmount!.toStringAsFixed(2)} ${widget.toCurrency}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
