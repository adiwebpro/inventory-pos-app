import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_inventory_app/services/api_service.dart';

class ProcessPaymentScreen extends StatefulWidget {
  const ProcessPaymentScreen({super.key});

  @override
  _ProcessPaymentScreenState createState() => _ProcessPaymentScreenState();
}

class _ProcessPaymentScreenState extends State<ProcessPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _transactionId = '';
  String _paymentMethod = 'cash';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔙 Tombol kembali dan judul
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  "Proses Pembayaran",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 🧾 Form pembayaran
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'ID Transaksi',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Masukkan ID Transaksi' : null,
                        onSaved: (value) => _transactionId = value!,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        items: const [
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(
                            value: 'credit_card',
                            child: Text('Credit Card'),
                          ),
                          DropdownMenuItem(
                            value: 'debit_card',
                            child: Text('Debit Card'),
                          ),
                          DropdownMenuItem(
                            value: 'e_wallet',
                            child: Text('E-Wallet'),
                          ),
                        ],
                        onChanged:
                            (value) => setState(() => _paymentMethod = value!),
                        decoration: const InputDecoration(
                          labelText: 'Metode Pembayaran',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child:
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _processPayment,
                                  child: Text(
                                    'Proses Pembayaran',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final response = await api.post('transactions/$_transactionId/process', {
        'payment_method': _paymentMethod,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil diproses')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memproses pembayaran')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
