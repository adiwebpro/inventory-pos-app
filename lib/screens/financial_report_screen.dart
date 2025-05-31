// lib/screens/financial_report_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pos_inventory_app/services/api_service.dart';
import 'package:intl/intl.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  _FinancialReportScreenState createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    try {
      final api = ApiService();
      final response = await api.get('reports/financial');
      if (response.statusCode == 200) {
        setState(() {
          _reportData = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load financial data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Keuangan')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFinancialCard(
                      'Pendapatan',
                      _reportData['total_income'],
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildFinancialCard(
                      'Pengeluaran',
                      _reportData['total_expenses'],
                      Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildFinancialCard(
                      'Laba',
                      _reportData['profit'],
                      Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_reportData['transactions'] as List<dynamic>)
                        .map<Widget>((transaction) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text('Transaksi #${transaction['id']}'),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy HH:mm').format(
                                  DateTime.parse(transaction['created_at']),
                                ),
                              ),
                              trailing: Text(
                                NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(transaction['total_amount']),
                              ),
                            ),
                          );
                        })
                        ,
                  ],
                ),
              ),
    );
  }

  Widget _buildFinancialCard(String title, double amount, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(amount),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
