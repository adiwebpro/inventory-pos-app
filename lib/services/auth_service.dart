// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.109.66:8000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['access_token']);
        await _storage.write(key: 'user', value: jsonEncode(data['user']));
        _currentUser = data['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.109.66:8000/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['access_token']);
        await _storage.write(key: 'user', value: jsonEncode(data['user']));
        _currentUser = data['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    try {
      final userJson = await _storage.read(key: 'user');
      if (userJson != null) {
        _currentUser = jsonDecode(userJson);
        notifyListeners();
      }
    } catch (e) {
      print('Load user error: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    await loadUser();
    return _currentUser != null;
  }
}
