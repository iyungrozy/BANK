import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TopUpBottomSheet extends StatefulWidget {
  final String selectedProvider;
  final String account;
  final String image;

  const TopUpBottomSheet({
    super.key,
    required this.selectedProvider,
    required this.account,
    required this.image,
  });

  @override
  State<TopUpBottomSheet> createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends State<TopUpBottomSheet> {
  double amount = 100000.0; // Default amount in IDR

  // Function to perform top up to the API
  Future<void> _topUp() async {
    final response = await http.post(
      Uri.parse("http://103.47.225.247:5000/api/input_saldo"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'account_number': widget.account, // Get account number from widget
        'account_type': 'SAVINGS', // Hardcoded as "SAVINGS"
        'currency_code': 'IDR', // Use IDR instead of USD
        'available_balance': amount.toStringAsFixed(2), // Convert amount to string with two decimal places
      }),
    );

    if (response.statusCode == 200) {
      // Show success message if successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Top Up berhasil!')),
      );
      Navigator.pop(context); // Close bottom sheet after success
    } else {
      // Show error message if failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Top Up gagal!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Wrap in a SingleChildScrollView to prevent overflow
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage(widget.image),
                backgroundColor: Colors.white,
              ),
              title: Text(widget.selectedProvider),
              subtitle: Text(widget.account),
              trailing: const Icon(
                Icons.keyboard_arrow_down,
                size: 25,
                color: Colors.grey,
              ),
              contentPadding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(
                  color: Colors.black12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Amount (IDR)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (amount > 5000) amount -= 5000; // Decrease amount by 5000 IDR
                    });
                  },
                  icon: const Icon(Icons.remove),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Text(
                  "IDR ${amount.toStringAsFixed(0)}", // Show amount in IDR
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      amount += 5000; // Increase amount by 5000 IDR
                    });
                  },
                  icon: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Slider(
              value: amount,
              min: 5000, // Minimum value set to 5000 IDR
              max: 500000, // Maximum value set to 500000 IDR
              activeColor: const Color.fromARGB(255, 16, 80, 98),
              onChanged: (value) {
                setState(() {
                  amount = value; // Adjust the slider value
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [5000, 10000, 20000, 50000, 100000, 200000, 500000]
                    .map((value) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        amount = value.toDouble(); // Select predefined amount
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: amount == value
                              ? const Color.fromARGB(255, 16, 80, 98)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        'IDR $value', // Display predefined amount in IDR
                        style: TextStyle(
                            color: amount == value ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _topUp, // Call the top-up function on press
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(double.maxFinite, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text(
                "Top Up",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
