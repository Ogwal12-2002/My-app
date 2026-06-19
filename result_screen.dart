import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/url_validator.dart';
import '../../models/scan_record.dart';
import '../../services/share_service.dart';
import 'widgets/result_action_bar.dart';

/// Displays a single [ScanRecord]: its type, decoded content, timestamp,
/// and available actions (copy / share / open link). Reached either by
/// scanning (record arrives via route arguments) or by tapping a History
/// row (same mechanism).
class ResultScreen extends StatelessWidget {
  final ScanRecord record;

  const ResultScreen({super.key, required this.record});

  IconData get _typeIcon {
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

  String get _typeLabel => ScanClassifier.formatLabel(record.format);

  @override
  Widget build(BuildContext context) {
    final isUrl = UrlValidator.isUrl(record.content);

    return Scaffold(
      appBar: AppBar(
        title: Text(record.isGenerated ? 'Generated Code' : 'Scan Result'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_typeIcon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(_typeLabel, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        record.content.isEmpty ? '(empty content)' : record.content,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                DateFormatter.full(record.scannedAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              ResultActionBar(
                showOpenLink: isUrl,
                onCopy: () async {
                  await ShareService.copyToClipboard(record.content);
                  if (context.mounted) {
                    _showSnack(context, 'Copied to clipboard');
                  }
                },
                onShare: () => ShareService.shareText(record.content),
                onOpenLink: isUrl
                    ? () async {
                        final opened = await ShareService.openUrl(record.content);
                        if (!opened && context.mounted) {
                          _showSnack(context, 'Could not open this link');
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
