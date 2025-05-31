// lib/screens/sales_report_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pos_inventory_app/services/api_service.dart';
import 'package:intl/intl.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  _SalesReportScreenState createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  double _totalSales = 0;

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    try {
      final api = ApiService();
      final response = await api.get('reports/sales');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _transactions = data['transactions'];
          _totalSales = data['total_sales'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load sales data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Total Penjualan',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(_totalSales),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return ListTile(
                          title: Text('Transaksi #${transaction['id']}'),
                          subtitle: Text(
                            DateFormat(
                              'dd MMM yyyy HH:mm',
                            ).format(DateTime.parse(transaction['created_at'])),
                          ),
                          trailing: Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(transaction['total_amount']),
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
