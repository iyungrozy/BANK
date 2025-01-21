import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  Future<Map<String, dynamic>> fetchTransactions() async {
    const url = 'https://nibank.honjo.web.id/api/saldo';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final transactions = snapshot.data!['transactions'] as List<dynamic>;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final description = transaction['description'];
                final amount = transaction['transaction_amount'];
                final type = transaction['transaction_type'];
                final date = transaction['transaction_date'];

                // Determine styling based on transaction type
                final isCredit = type == 'CR';
                final amountColor = isCredit ? Colors.teal : Colors.red;
                final amountSign = isCredit ? '+' : '-';

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 239, 243, 245),
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? Colors.teal : Colors.red,
                        ),
                      ),
                      title: Text(description),
                      subtitle: Text(date),
                      trailing: Text(
                        '$amountSign\$${amount.toStringAsFixed(2)}',
                        style: TextStyle(color: amountColor),
                      ),
                    ),
                    Divider(color: Colors.grey[200]),
                  ],
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
