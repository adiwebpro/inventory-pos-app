import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.139.58.37:8000/api';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        throw Exception('No token found in storage');
      }
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        ...?additionalHeaders,
      };
    } catch (e) {
      print('Error reading token: $e');
      rethrow;
    }
  }

  // Method GET
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(additionalHeaders: headers),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  // Method POST
  Future<http.Response> post(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(additionalHeaders: headers),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  // Method PUT
  Future<http.Response> put(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(additionalHeaders: headers),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  // Method DELETE
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(additionalHeaders: headers),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  // ===========================
  // ===== CUSTOM METHODS =====
  // ===========================

  // Produk
  Future<http.Response> getProducts() => get('products');

  Future<http.Response> createProduct(Map<String, dynamic> data) =>
      post('products', data);

  Future<http.Response> editProduct(String id, Map<String, dynamic> data) =>
      put('products/$id', data);

  Future<http.Response> deleteProduct(String id) =>
      delete('products/$id');

  Future<http.Response> updateStock(String id, int newStock) =>
      put('products/$id/stock', {'stock': newStock});

  // User
  Future<http.Response> getUsers() => get('users');

  Future<http.Response> updateUser(String id, Map<String, dynamic> data) =>
      put('users/$id', data);

  Future<http.Response> deleteUser(String id) =>
      delete('users/$id');

  // Transaksi
  Future<http.Response> getTransactions() => get('transactions');

  Future<http.Response> processPayment(String transactionId) =>
      post('transactions/$transactionId/process', {});

  // Laporan
  Future<http.Response> getSalesReport() => get('reports/sales');

  Future<http.Response> getFinancialReport() => get('reports/financial');

  // Aktivitas dan Kinerja
  Future<http.Response> getActivities() => get('activities');

  Future<http.Response> getStaffPerformance() =>
      get('reports/staff-performance');
}
