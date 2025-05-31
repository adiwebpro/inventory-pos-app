import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ProductApi {
  static const String baseUrl =
      'http://192.168.109.66:8000/api'; // Ganti dengan URL API Anda

  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    File? imageFile,
    Uint8List? webImage,
  }) async {
    try {
      // 1. Buat multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/products'), // Sesuaikan endpoint
      );

      // 2. Tambahkan headers dasar
      request.headers['Accept'] = 'application/json';

      // 3. Tambahkan field form
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['stock'] = stock.toString();

      // 4. Tambahkan file jika ada
      if (kIsWeb && webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            webImage,
            filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      } else if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      // 5. Kirim request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      // 6. Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseData);
      } else {
        throw Exception('''
Server error: ${response.statusCode}
Response: ${responseData.length > 200 ? '${responseData.substring(0, 200)}...' : responseData}
''');
      }
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }
}
