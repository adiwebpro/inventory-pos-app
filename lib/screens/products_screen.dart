import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_inventory_app/services/api_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load products')));
    }
  }

  Future<void> _searchProducts() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final response = await api.get('products/search?query=$_searchQuery');
      if (response.statusCode == 200) {
        setState(() {
          _products = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to search products')),
      );
    }
  }

  Future<void> _addToCart(String productId) async {
    try {
      final api = ApiService();
      final response = await api.post('carts', {
        'product_id': productId,
        'quantity': 1,
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to cart')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Text(
            "Product List",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => _searchQuery = value,
                onSubmitted: (_) => _searchProducts(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
              : Expanded(
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final price =
                        double.tryParse(product['price'].toString()) ?? 0.0;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              product['image'] != null
                                  ? Image.network(
                                    product['image'].toString(),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                  : const Icon(Icons.image, size: 40),
                        ),
                        title: Text(
                          product['name'].toString(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Rp ${NumberFormat('#,###').format(price)}',
                          style: GoogleFonts.poppins(color: Colors.grey[700]),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          color: Colors.blue.shade700,
                          onPressed: () => _addToCart(product['id'].toString()),
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
