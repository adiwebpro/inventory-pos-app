// add_product_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_inventory_app/services/api_service.dart';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? productData;
  final bool isEditMode;

  const AddProductPage({
    Key? key,
    this.productData,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.productData != null) {
      _nameController.text = widget.productData!['name'];
      _priceController.text = widget.productData!['price'].toString();
      _stockController.text = widget.productData!['stock'].toString();
    }
  }

  Future<void> _submitProduct() async {
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());

    if (name.isEmpty || price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon isi semua data dengan benar')),
      );
      return;
    }

    final product = {
      'name': name,
      'price': price,
      'stock': stock,
    };

    try {
      final response = widget.isEditMode
          ? await _apiService.put('products/${widget.productData!['id']}', product)
          : await _apiService.post('products', product);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true); // <-- Penting agar ProductsScreen refresh
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
          widget.isEditMode ? 'Edit Produk' : 'Tambah Produk',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _stockController,
              decoration: InputDecoration(
                labelText: 'Stok',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitProduct,
              child: Text(widget.isEditMode ? 'Simpan' : 'Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
