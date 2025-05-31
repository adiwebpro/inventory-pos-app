import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_inventory_app/services/api_service.dart';
import 'dart:convert';

class UserFormScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const UserFormScreen({super.key, this.user});

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String _role = 'buyer';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?['name'] ?? '');
    _emailController = TextEditingController(text: widget.user?['email'] ?? '');
    _passwordController = TextEditingController();
    _role = widget.user?['role'] ?? 'buyer';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final api = Provider.of<ApiService>(context, listen: false);
    final body = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'role': _role,
    };

    if (widget.user == null) {
      body['password'] = _passwordController.text;
    }

    try {
      final response =
          widget.user == null
              ? await api.post('users', body)
              : await api.put('users/${widget.user!['id']}', body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        final resBody = response.body;
        String errorMessage = 'Gagal menyimpan pengguna';
        try {
          final decoded = jsonDecode(resBody);
          if (decoded is Map && decoded['message'] != null) {
            errorMessage = decoded['message'];
          } else if (decoded is Map && decoded['errors'] != null) {
            errorMessage = decoded['errors'].toString();
          }
        } catch (_) {
          errorMessage = resBody.toString();
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Tambah Pengguna' : 'Edit Pengguna'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Nama wajib diisi'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Email wajib diisi';
                              }
                              final emailRegex = RegExp(r'^\S+@\S+\.\S+$');
                              if (!emailRegex.hasMatch(val)) {
                                return 'Email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (widget.user == null)
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator:
                                  (val) =>
                                      val == null || val.length < 6
                                          ? 'Password minimal 6 karakter'
                                          : null,
                            ),
                          if (widget.user == null) const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _role,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'buyer',
                                child: Text('Buyer'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                              DropdownMenuItem(
                                value: 'cashier',
                                child: Text('Cashier'),
                              ),
                              DropdownMenuItem(
                                value: 'stock_counter',
                                child: Text('Stock Counter'),
                              ),
                              DropdownMenuItem(
                                value: 'owner',
                                child: Text('Owner'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _role = val);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saveUser,
                              icon: const Icon(Icons.save),
                              label: const Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
