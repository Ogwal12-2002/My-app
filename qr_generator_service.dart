import 'dart:typed_data';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Handles writing a captured QR image (as PNG bytes, produced by the
/// `screenshot` package in the UI layer) to a file in app storage so it
/// can be shared or referenced. Kept separate from UI so the save logic
/// is independently testable.
class QrGeneratorService {
  static Future<File> saveImage(Uint8List bytes, {String? fileName}) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = fileName ?? 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${dir.path}/$name');
    return file.writeAsBytes(bytes);
  }
}
