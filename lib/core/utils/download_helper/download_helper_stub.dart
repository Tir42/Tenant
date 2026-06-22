 import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

void downloadPdf(String filename, Uint8List bytes) async {
  String? savedPath;

  try {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt <= 29) {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          try {
            final downloadDir = Directory('/storage/emulated/0/Download');
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }
            final path = '${downloadDir.path}/$filename';
            final file = File(path);
            await file.writeAsBytes(bytes);
            savedPath = file.path;
          } catch (e) {
            // Fallback to app directory
          }
        }
      }

      if (savedPath == null) {
        // Fallback to app's external storage directory
        final extDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        final path = '${extDir.path}/$filename';
        final file = File(path);
        await file.writeAsBytes(bytes);
        savedPath = file.path;
      }
    } else if (Platform.isIOS) {
      // Save directly to the Application Documents Directory on iOS
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      await file.writeAsBytes(bytes);
      savedPath = file.path;
    }
  } catch (e) {
    // Fail silently
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
