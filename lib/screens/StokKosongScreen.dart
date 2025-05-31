import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_inventory_app/services/api_service.dart';

class StokKosongScreen extends StatefulWidget {
  const StokKosongScreen({super.key});

  @override
  State<StokKosongScreen> createState() => _StokKosongScreenState();
}

class _StokKosongScreenState extends State<StokKosongScreen> {
  List<Map<String, dynamic>> emptyStockProducts = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchEmptyStockProducts();
  }

  Future<void> fetchEmptyStockProducts() async {
    try {
      final response = await apiService.getProducts();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          emptyStockProducts =
              data
                  .map((e) => e as Map<String, dynamic>)
                  .where((product) => product['stock'] == 0)
                  .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data produk')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Produk Stok Kosong',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : emptyStockProducts.isEmpty
                ? Center(
                  child: Text(
                    'Tidak ada produk dengan stok kosong.',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                )
                : ListView.builder(
                  itemCount: emptyStockProducts.length,
                  itemBuilder: (context, index) {
                    final product = emptyStockProducts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          product['name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Stok: 0',
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade700,
                          ),
                        ),
                        trailing: Icon(
                          Icons.warning,
                          color: Colors.red.shade700,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
