import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/constants.dart';
import '../models/scan_record.dart';
import '../services/database_service.dart';

/// Lightweight state for the Scanner screen: whether scanning is currently
/// paused (e.g. right after a successful detection, to avoid re-triggering
/// on the same code), and any error message to display. Torch state is
/// owned directly by [MobileScannerController.torchState] and is not
/// duplicated here.
class ScannerState {
  final bool isPaused;
  final String? errorMessage;

  const ScannerState({
    this.isPaused = false,
    this.errorMessage,
  });

  ScannerState copyWith({
    bool? isPaused,
    String? errorMessage,
  }) {
    return ScannerState(
      isPaused: isPaused ?? this.isPaused,
      errorMessage: errorMessage,
    );
  }
}

/// Manages scanner UI state and persists successful detections to the DB.
/// The [MobileScannerController] itself is owned by the screen (it's a
/// platform-view-backed controller tied to widget lifecycle), and this
/// provider owns everything that should survive rebuilds: pause state and
/// the save-on-detect logic.
class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier() : super(const ScannerState());

  void pause() {
    state = state.copyWith(isPaused: true);
  }

  void resume() {
    state = state.copyWith(isPaused: false, errorMessage: null);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  /// Persists a successful detection and returns the saved [ScanRecord].
  /// Called by the Scanner screen right before navigating to Result.
  Future<ScanRecord> handleDetection(BarcodeCapture capture) async {
    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue ?? '';
    final format = barcode.format.name;

    final type = ScanClassifier.classify(content: rawValue, format: format);

    final record = ScanRecord(
      content: rawValue,
      format: format,
      type: type,
      scannedAt: DateTime.now(),
      isGenerated: false,
    );

    return DatabaseService.instance.insert(record);
  }
}

final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>(
  (ref) => ScannerNotifier(),
);
