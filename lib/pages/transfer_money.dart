import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransferMoney extends StatefulWidget {
  const TransferMoney({super.key});

  @override
  State<TransferMoney> createState() => _TransferMoneyState();
}

class _TransferMoneyState extends State<TransferMoney> {
  List<Map<String, dynamic>> cards = [];
  String? selectedCard;
  String destinationAccount = '';
  double transferAmount = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  Future<void> fetchCards() async {
    const String apiUrl = 'https://nibank.honjo.web.id/api/saldo';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          cards = List<Map<String, dynamic>>.from(data['accounts']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching cards: $e');
    }
  }

  Future<void> transferMoney() async {
    const String transferUrl = 'http://103.47.225.247:5000/api/transfer';
    if (selectedCard == null || destinationAccount.isEmpty || transferAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly')),
      );
      return;
    }

    final payload = {
      "source_account_number": selectedCard,
      "destination_account_number": destinationAccount,
      "amount": transferAmount.toStringAsFixed(2),
    };

    try {
      final response = await http.post(
        Uri.parse(transferUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer successful!')),
        );
      } else {
        throw Exception('Failed to transfer money');
      }
    } catch (e) {
      print('Error transferring money: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to transfer money')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Source Card',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCard,
                    items: cards
                        .map(
                          (card) => DropdownMenuItem<String>(
                            value: card['account_number'],
                            child: Text('${card['account_name']} - ${card['account_number']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCard = value;
                      });
                    },
                    hint: const Text('Select a card'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Destination Account Number',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter destination account number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      destinationAccount = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Amount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      transferAmount = double.tryParse(value) ?? 0.0;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: transferMoney,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Transfer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
