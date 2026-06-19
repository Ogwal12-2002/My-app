import '../core/constants.dart';

/// Represents a single row in the `scan_history` table.
///
/// This is intentionally a plain data class with no business logic beyond
/// (de)serialization — classification logic lives in [ScanClassifier].
class ScanRecord {
  final int? id; // null until inserted into the DB
  final String content;
  final String format; // raw format from mobile_scanner, e.g. "QR_CODE"
  final ScanContentType type; // semantic classification
  final DateTime scannedAt;
  final bool isGenerated;

  ScanRecord({
    this.id,
    required this.content,
    required this.format,
    required this.type,
    required this.scannedAt,
    this.isGenerated = false,
  });

  /// Creates a copy with an updated id (used right after DB insert).
  ScanRecord copyWith({int? id}) {
    return ScanRecord(
      id: id ?? this.id,
      content: content,
      format: format,
      type: type,
      scannedAt: scannedAt,
      isGenerated: isGenerated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'format': format,
      'type': type.name,
      'scanned_at': scannedAt.millisecondsSinceEpoch,
      'is_generated': isGenerated ? 1 : 0,
    };
  }

  factory ScanRecord.fromMap(Map<String, dynamic> map) {
    return ScanRecord(
      id: map['id'] as int,
      content: map['content'] as String,
      format: map['format'] as String,
      type: ScanContentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ScanContentType.unknown,
      ),
      scannedAt: DateTime.fromMillisecondsSinceEpoch(map['scanned_at'] as int),
      isGenerated: (map['is_generated'] as int) == 1,
    );
  }
}
