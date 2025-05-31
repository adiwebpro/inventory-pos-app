import 'package:flutter/material.dart';

class StockReportScreen extends StatelessWidget {
  const StockReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh laporan stok sederhana
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Stok')),
      body: const Center(
        child: Text(
          'Laporan stok produk akan ditampilkan di sini.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
