import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.188.66:8000/api';
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

  // Custom methods
  Future<http.Response> getProducts() => get('products');
  Future<http.Response> updateProduct(String id, Map<String, dynamic> data) =>
      put('products/$id', data);
  Future<http.Response> updateStock(String id, int newStock) =>
      put('products/$id/stock', {'stock': newStock});
  Future<http.Response> getUsers() => get('users');
  Future<http.Response> updateUser(String id, Map<String, dynamic> data) =>
      put('users/$id', data);
  Future<http.Response> deleteUser(String id) => delete('users/$id');
  Future<http.Response> getTransactions() => get('transactions');
  Future<http.Response> processPayment(String transactionId) =>
      post('transactions/$transactionId/process', {});
  Future<http.Response> getSalesReport() => get('reports/sales');
  Future<http.Response> getFinancialReport() => get('reports/financial');
  Future<http.Response> getActivities() => get('activities');
  Future<http.Response> getStaffPerformance() =>
      get('reports/staff-performance');

  Future createProduct(Map<String, Object> newProduct) async {}
}
