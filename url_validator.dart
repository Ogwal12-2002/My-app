/// Small helper for URL-related checks used by the Result screen
/// (e.g. deciding whether to show the "Open link" action).
class UrlValidator {
  static bool isUrl(String content) {
    final trimmed = content.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return false;
    }
    return Uri.tryParse(trimmed)?.hasAuthority ?? false;
  }
}
