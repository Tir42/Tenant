import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes, debugPrint;
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> fetchImageBytes(String path) async {
  try {
    if (path.startsWith('assets/')) {
      final byteData = await rootBundle.load(path);
      return byteData.buffer.asUint8List();
    }
    if (path.startsWith('http')) {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(path));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      return bytes;
    }
    // Otherwise it's a local file
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
  } catch (e) {
    debugPrint("Error loading native image bytes: $e");
  }
  return Uint8List(0);
}
