import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pos_inventory_app/services/api_service.dart';
import 'package:provider/provider.dart';

class SystemActivitiesScreen extends StatelessWidget {
  const SystemActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aktivitas Sistem')),
      body: const SystemLogsScreenBody(),
    );
  }
}

class SystemLogsScreenBody extends StatefulWidget {
  const SystemLogsScreenBody({super.key});

  @override
  _SystemLogsScreenBodyState createState() => _SystemLogsScreenBodyState();
}

class _SystemLogsScreenBodyState extends State<SystemLogsScreenBody> {
  List<dynamic> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final response = await api.get('activities');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _logs = data['activities'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat log sistem. Status code: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat log sistem')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_logs.isEmpty) {
      return const Center(child: Text('Tidak ada log tersedia'));
    }
    return ListView.builder(
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(log.toString()),
        );
      },
    );
  }
}
