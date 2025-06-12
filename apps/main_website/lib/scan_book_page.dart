import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // For web file upload
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert'; // For JSON decoding


class ScanBookPage extends StatefulWidget {
  const ScanBookPage({super.key});

  @override
  State<ScanBookPage> createState() => _ScanBookPageState();
}

class _ScanBookPageState extends State<ScanBookPage> {
  final ApiService _apiService = ApiService();
  String? _result;
  bool _isLoading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final result = await _apiService.uploadImage(image);
        setState(() {
          _result =
              'Extracted Text: ${result['extracted_text']}\n\n'
              'Book Details: ${result['book_details']}';
        });
      } catch (e) {
        setState(() => _result = 'Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _pickAndUploadImage,
              child: Text(_isLoading ? 'Processing...' : 'Take Picture'),
            ),
            if (_isLoading) const CircularProgressIndicator(),
            if (_result != null)
              Expanded(child: SingleChildScrollView(child: Text(_result!))),
          ],
        ),
      ),
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  Future<Map<String, dynamic>> uploadImage(XFile image) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/'));

    if (kIsWeb) {
      // For web, read the file as bytes
      Uint8List bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: image.name),
      );
    } else {
      // For mobile, use fromPath
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else {
      throw Exception('Failed to upload image');
    }
  }
}
