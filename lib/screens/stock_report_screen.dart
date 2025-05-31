import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_inventory_app/services/api_service.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  _StockReportScreenState createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    try {
      final api = ApiService();
      final response = await api.get('products');
      if (response.statusCode == 200) {
        setState(() {
          _products = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load stock data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Stok',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                ? Center(
                  child: Text(
                    'Tidak ada data stok',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                )
                : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final price =
                        double.tryParse(product['price'].toString()) ?? 0.0;
                    final stock = product['stock'] ?? 0;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          product['name'].toString(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Stok: $stock',
                          style: GoogleFonts.poppins(
                            color: const Color.fromARGB(255, 240, 239, 239),
                          ),
                        ),
                        trailing: Text(
                          'Rp ${NumberFormat('#,###').format(price)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
