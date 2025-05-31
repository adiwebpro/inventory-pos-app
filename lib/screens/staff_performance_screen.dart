// lib/screens/staff_performance_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pos_inventory_app/services/api_service.dart';

class StaffPerformanceScreen extends StatefulWidget {
  const StaffPerformanceScreen({super.key});

  @override
  _StaffPerformanceScreenState createState() => _StaffPerformanceScreenState();
}

class _StaffPerformanceScreenState extends State<StaffPerformanceScreen> {
  List<dynamic> _staffs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaffPerformance();
  }

  Future<void> _fetchStaffPerformance() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final response = await api.get('reports/staff-performance');
      if (response.statusCode == 200) {
        setState(() {
          _staffs = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data performa staff')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performa Staff')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _staffs.length,
                itemBuilder: (context, index) {
                  final staff = _staffs[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(staff['name']),
                      subtitle: Text(staff['role']),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Transaksi: ${staff['transaction_count']}'),
                          Text(
                            'Total: Rp ${NumberFormat('#,###').format(staff['total_sales'])}',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
