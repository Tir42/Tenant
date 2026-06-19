// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> fetchImageBytes(String path) async {
  try {
    if (path.startsWith('assets/')) {
      final byteData = await rootBundle.load(path);
      return byteData.buffer.asUint8List();
    }
    // Web fetch works for http, https, and local blob URLs
    final response = await html.window.fetch(path);
    final buffer = await response.arrayBuffer();
    return Uint8List.view(buffer);
  } catch (e) {
    // Return empty on failure
    return Uint8List(0);
  }
}
