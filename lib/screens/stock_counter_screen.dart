import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pos_inventory_app/screens/KelolaStokScreen.dart';
import 'package:pos_inventory_app/screens/StokKosongScreen.dart';
import 'package:provider/provider.dart';
import 'package:pos_inventory_app/services/api_service.dart';
import 'package:pos_inventory_app/services/auth_service.dart';
import 'package:pos_inventory_app/screens/product_management_screen.dart';
import 'package:pos_inventory_app/screens/stock_report_screen.dart';
// import layar stok kosong
import 'add_product_page.dart';

class StockCounterScreen extends StatefulWidget {
  const StockCounterScreen({super.key});

  @override
  State<StockCounterScreen> createState() => _StockCounterScreenState();
}

class _StockCounterScreenState extends State<StockCounterScreen> {
  String searchQuery = '';

  List<Map<String, dynamic>> allProducts = [];

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
          allProducts =
              data.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil data produk')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (searchQuery.isEmpty) {
      return allProducts;
    } else {
      return allProducts
          .where(
            (prod) =>
                prod['name'].toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6EDED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // agar tidak overflow saat keyboard muncul
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "POS",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C464F),
                          ),
                        ),
                        Text(
                          "Inventory",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1C464F),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.notifications_none, size: 28),
                        SizedBox(width: 12),
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage('assets/user.png'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Greeting Card
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Halo Stock Counter ${user?['name'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3 Menu Boxes
                Row(
                  children: [
                    _buildActionBox(
                      context,
                      icon: Icons.list_alt,
                      label: "Kelola Stok",
                      color: Colors.blue.shade600,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KelolaStokScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildActionBox(
                      context,
                      icon: Icons.assessment,
                      label: "Laporan Stok",
                      color: Colors.blue.shade600,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StockReportScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildActionBox(
                      context,
                      icon: Icons.warning_amber_outlined,
                      label: "Stok Kosong",
                      color: Colors.blue.shade600,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StokKosongScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Search & Tambah Produk
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Navigate ke AddProductPage, tunggu sampai selesai
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductPage(),
                          ),
                        );
                        // Setelah kembali, refresh produk
                        await fetchProducts();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Tambah"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Daftar Produk hasil filter
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(product['name']),
                        subtitle: Text('Stok: ${product['stock']}'),
                        trailing:
                            product['stock'] == 0
                                ? Icon(
                                  Icons.warning,
                                  color: Colors.blue.shade600,
                                )
                                : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBox(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Function() onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
