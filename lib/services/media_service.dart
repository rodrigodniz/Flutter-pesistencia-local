import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MediaService {
  // Android Emulator: aponta pro PC
  // Celular físico: use http://SEU_IP_LOCAL:3001
  final String baseUrl = 'http://10.0.2.2:3001';

  Future<String?> uploadBase64({
    required File file,
    String mimeType = 'image/jpeg',
  }) async {
    final bytes = await file.readAsBytes();
    final base64Data = base64Encode(bytes);

    final fileName = 'task_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final resp = await http.post(
      Uri.parse('$baseUrl/upload'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fileName': fileName,
        'mimeType': mimeType,
        'base64Data': base64Data,
      }),
    );

    if (resp.statusCode == 201) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      return body['url'] as String?;
    }

    return null;
  }
}
