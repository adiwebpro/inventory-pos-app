import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pos_inventory_app/services/api_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      String url = 'transactions';

      if (_dateRange != null) {
        final start = _dateRange!.start.toIso8601String();
        final end = _dateRange!.end.toIso8601String();
        url += '?start_date=$start&end_date=$end';
      }

      final response = await api.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _transactions = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat riwayat transaksi')),
      );
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _isLoading = true;
      });
      _fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // <-- Warna latar belakang diubah di sini
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _selectDateRange(context),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Pilih Tanggal'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _fetchTransactions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Muat Ulang'),
                  ),
                ],
              ),
            ),
            _isLoading
                ? const Expanded(child: Center(child: CircularProgressIndicator()))
                : _transactions.isEmpty
                    ? const Expanded(child: Center(child: Text('Tidak ada transaksi')))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            final createdAt =
                                DateTime.parse(transaction['created_at']);
                            final total = transaction['total_amount'];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ExpansionTile(
                                title: Text('Transaksi #${transaction['id']}'),
                                subtitle: Text(
                                  DateFormat('dd MMM yyyy HH:mm').format(createdAt),
                                ),
                                trailing: Text(
                                  'Rp ${NumberFormat('#,###').format(total)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        ...transaction['items']
                                            .map<Widget>((item) {
                                          return ListTile(
                                            title:
                                                Text(item['product']['name']),
                                            subtitle: Text(
                                              '${item['quantity']} x Rp ${NumberFormat('#,###').format(item['price'])}',
                                            ),
                                            trailing: Text(
                                              'Rp ${NumberFormat('#,###').format(item['price'] * item['quantity'])}',
                                            ),
                                          );
                                        }).toList(),
                                        const Divider(),
                                        ListTile(
                                          title:
                                              const Text('Metode Pembayaran'),
                                          trailing: Text(
                                              transaction['payment_method']),
                                        ),
                                        ListTile(
                                          title: const Text('Status'),
                                          trailing: Chip(
                                            label: Text(
                                              transaction['status'],
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor:
                                                transaction['status'] ==
                                                        'completed'
                                                    ? Colors.green
                                                    : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
