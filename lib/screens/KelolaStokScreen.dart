import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_inventory_app/services/api_service.dart';

class KelolaStokScreen extends StatefulWidget {
  const KelolaStokScreen({super.key});

  @override
  State<KelolaStokScreen> createState() => _KelolaStokScreenState();
}

class _KelolaStokScreenState extends State<KelolaStokScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await apiService.getProducts();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          products = data.map((e) => e as Map<String, dynamic>).toList();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kelola Stok',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 24),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                ? const Center(child: Text('Belum ada produk.'))
                : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final stock = product['stock'] ?? 0;
                    final isEmpty = stock == 0;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          product['name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Stok: $stock',
                          style: GoogleFonts.poppins(
                            color: isEmpty ? Colors.red : Colors.grey[700],
                          ),
                        ),
                        trailing:
                            isEmpty
                                ? const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                )
                                : const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
