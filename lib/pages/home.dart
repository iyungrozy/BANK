import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk JSON decoding
import 'package:http/http.dart' as http; // Untuk HTTP request

import '../widgets/action_button.dart';
import '../widgets/transaction_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String customerName = "Loading..."; // Placeholder untuk nama pelanggan
  List transactions = []; // Placeholder untuk daftar transaksi

  // Fungsi untuk mengambil data dari API
  Future<void> fetchData() async {
    const url = 'https://nibank.honjo.web.id/api/saldo';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // Decode JSON
        setState(() {
          customerName = data['customer_name'] ?? "No Name";
          transactions = data['transactions'] ?? [];
        });
      } else {
        // Handle jika gagal mendapatkan data
        setState(() {
          customerName = "Failed to load data";
        });
      }
    } catch (error) {
      // Handle jika terjadi error
      setState(() {
        customerName = "Error occurred";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Panggil fetchData saat widget pertama kali dibangun
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 80, 98),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back!",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        customerName, // Menggunakan nama pelanggan dari API
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton.outlined(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const ActionButtons(), // Tetap statis
                    const SizedBox(height: 30),
                    // TransactionList menggunakan transaksi dari API
                    TransactionList(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
