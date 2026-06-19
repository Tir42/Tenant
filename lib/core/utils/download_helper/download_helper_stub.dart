import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void downloadPdf(String filename, Uint8List bytes) async {
  try {
    if (Platform.isAndroid) {
      // Try to save directly to the public Download folder on Android
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        final path = '${downloadDir.path}/$filename';
        final file = File(path);
        await file.writeAsBytes(bytes);
      } else {
        // Fallback to app's external storage directory
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final path = '${extDir.path}/$filename';
          final file = File(path);
          await file.writeAsBytes(bytes);
        }
      }
    } else if (Platform.isIOS) {
      // Save directly to the Application Documents Directory on iOS.
      // With UISupportsDocumentBrowser enabled in Info.plist, this folder is fully browseable in the Files app.
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      await file.writeAsBytes(bytes);
    }
  } catch (e) {
    // Direct save failed (e.g. storage permissions or system directory constraints)
  }

  // Always save to temp and present the share sheet as a fallback and additional user action
  try {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$filename';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(tempPath)],
        subject: 'TenantSnap Inspection Report',
        text: 'Here is your TenantSnap Inspection Report.',
      ),
    );
  } catch (e) {
    // Fail silently
  }
}
