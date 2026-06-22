import 'dart:io';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DownloadHelper {
    static Future<String?> downloadPdf({
        required Uint8List bytes,
        required String fileName,
    }) async {
        try {
            final safeFileName =
            fileName.toLowerCase().endsWith('.pdf') ? fileName : '$fileName.pdf';

            Directory? directory;
            if (Platform.isAndroid) {
                directory = await getExternalStorageDirectory();
            } else {
                directory = await getApplicationDocumentsDirectory();
            }

            if (directory == null) {
                return null;
            }

            final file = File('${directory.path}/$safeFileName');

            await file.writeAsBytes(bytes, flush: true);


            return file.path;
            
        } catch (e) {
            return null;
        }
    }
}