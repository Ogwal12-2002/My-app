import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/scan_record.dart';

/// Single row in the History list. Wrapped in a [Dismissible] by the
/// caller (History screen) to provide swipe-to-delete.
class HistoryTile extends StatelessWidget {
  final ScanRecord record;
  final VoidCallback onTap;

  const HistoryTile({super.key, required this.record, required this.onTap});

  IconData get _icon {
    switch (record.type) {
      case ScanContentType.url:
        return Icons.link;
      case ScanContentType.barcodeProduct:
        return Icons.qr_code_2;
      case ScanContentType.text:
        return Icons.notes;
      case ScanContentType.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          record.content.isEmpty ? '(empty content)' : record.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            record.isGenerated
                ? 'Generated · ${DateFormatter.relative(record.scannedAt)}'
                : DateFormatter.relative(record.scannedAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
