import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wraps clipboard, share-sheet, and URL-launching logic so screens don't
/// talk to three different plugins directly.
class ShareService {
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }

  /// Returns true if the URL was successfully launched.
  static Future<bool> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
