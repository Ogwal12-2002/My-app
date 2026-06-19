/// App-wide constants: route names and the semantic scan-type classification
/// used to decide which icon/actions to show on the Result screen.

/// Named routes used with Navigator.
class AppRoutes {
  static const String scanner = '/';
  static const String result = '/result';
  static const String history = '/history';
  static const String generator = '/generator';
}

/// Semantic classification of decoded content, independent of the raw
/// barcode *format* (EAN_13, QR_CODE, etc). This drives which icon and
/// which action buttons appear on the Result screen.
enum ScanContentType {
  url,
  text,
  barcodeProduct, // EAN/UPC style product codes
  unknown,
}

/// Helper to classify raw decoded content + format into a [ScanContentType].
class ScanClassifier {
  static ScanContentType classify({
    required String content,
    required String format,
  }) {
    final lower = content.trim().toLowerCase();

    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return ScanContentType.url;
    }

    // Product barcodes are numeric-only and use these formats.
    const productFormats = {
      'ean13',
      'ean8',
      'upca',
      'upce',
      'code128',
      'code39',
      'itf',
    };
    if (productFormats.contains(format.toLowerCase().replaceAll('_', ''))) {
      return ScanContentType.barcodeProduct;
    }

    if (content.trim().isEmpty) {
      return ScanContentType.unknown;
    }

    return ScanContentType.text;
  }

  /// Human-readable label for a scan format, e.g. "EAN-13 Barcode".
  static String formatLabel(String format) {
    final normalized = format.toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'qrcode':
        return 'QR Code';
      case 'ean13':
        return 'EAN-13 Barcode';
      case 'ean8':
        return 'EAN-8 Barcode';
      case 'upca':
        return 'UPC-A Barcode';
      case 'upce':
        return 'UPC-E Barcode';
      case 'code128':
        return 'Code 128 Barcode';
      case 'code39':
        return 'Code 39 Barcode';
      case 'itf':
        return 'ITF Barcode';
      case 'pdf417':
        return 'PDF417 Code';
      case 'aztec':
        return 'Aztec Code';
      case 'datamatrix':
        return 'Data Matrix Code';
      default:
        return format;
    }
  }
}

/// Database constants.
class DbConstants {
  static const String dbName = 'scan_history.db';
  static const int dbVersion = 1;
  static const String tableScanHistory = 'scan_history';
}
