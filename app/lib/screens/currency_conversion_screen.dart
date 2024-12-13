// currency_conversion_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyConversionScreen extends StatefulWidget {
  const CurrencyConversionScreen({super.key});

  @override
  State<CurrencyConversionScreen> createState() =>
      _CurrencyConversionScreenState();
}

class _CurrencyConversionScreenState extends State<CurrencyConversionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceCurrencyController =
      TextEditingController();
  final TextEditingController _targetCurrencyController =
      TextEditingController();
  String? _convertedAmount;

  Future<void> convertCurrency() async {
    final amount = _amountController.text.trim();
    final sourceCurrency = _sourceCurrencyController.text.toUpperCase().trim();
    final targetCurrency = _targetCurrencyController.text.toUpperCase().trim();

    if (amount.isEmpty || sourceCurrency.isEmpty || targetCurrency.isEmpty) {
      setState(() {
        _convertedAmount = 'Please fill all fields.';
      });
      return;
    }

    final url = 'https://api.exchangerate-api.com/v4/latest/$sourceCurrency';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][targetCurrency];
        if (rate != null) {
          final result = double.parse(amount) * rate;
          setState(() {
            _convertedAmount =
                '$amount $sourceCurrency = ${result.toStringAsFixed(2)} $targetCurrency';
          });
        } else {
          setState(() {
            _convertedAmount = 'Conversion rate not found.';
          });
        }
      } else {
        setState(() {
          _convertedAmount = 'Failed to fetch conversion rate.';
        });
      }
    } catch (e) {
      setState(() {
        _convertedAmount = 'Error occurred. Try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceCurrencyController,
              decoration: const InputDecoration(
                labelText: 'Source Currency (e.g., USD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetCurrencyController,
              decoration: const InputDecoration(
                labelText: 'Target Currency (e.g., EUR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: convertCurrency,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 20),
            if (_convertedAmount != null)
              Text(
                _convertedAmount!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
