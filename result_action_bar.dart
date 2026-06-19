import 'package:flutter/material.dart';

/// Row of action buttons shown at the bottom of the Result screen.
/// Open Link is conditionally rendered only when content is a valid URL.
class ResultActionBar extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onOpenLink;
  final bool showOpenLink;

  const ResultActionBar({
    super.key,
    required this.onCopy,
    required this.onShare,
    this.onOpenLink,
    this.showOpenLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_outlined, size: 18),
            label: const Text('Copy'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Share'),
          ),
        ),
        if (showOpenLink) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onOpenLink,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open'),
            ),
          ),
        ],
      ],
    );
  }
}
