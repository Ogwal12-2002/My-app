import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants.dart';
import '../../providers/scanner_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import 'widgets/scan_overlay.dart';
import 'widgets/torch_button.dart';

/// Home screen: full-screen camera preview with scan overlay, torch toggle,
/// and bottom navigation to History / Generator. Handles camera permission
/// requests and detection lifecycle (pause-on-detect, navigate, resume).
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with WidgetsBindingObserver {
  MobileScannerController? _controller;

  // Permission UI state. Kept local since it's purely presentational and
  // doesn't need to be shared with other screens.
  _PermissionStatus _permissionStatus = _PermissionStatus.checking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    // Guard: permission dialogs themselves trigger lifecycle events before
    // the controller has a camera permission grant — touching start/stop
    // during that window can crash or desync the controller.
    if (controller == null || !controller.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        controller.start();
        break;
      case AppLifecycleState.inactive:
        // Release the camera as soon as the app loses focus (covers both
        // backgrounding and the brief inactive state during app switches).
        controller.stop();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _checkAndRequestPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      _initController();
      return;
    }

    final result = await Permission.camera.request();
    if (result.isGranted) {
      _initController();
    } else if (result.isPermanentlyDenied) {
      setState(() => _permissionStatus = _PermissionStatus.permanentlyDenied);
    } else {
      setState(() => _permissionStatus = _PermissionStatus.denied);
    }
  }

  void _initController() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    setState(() => _permissionStatus = _PermissionStatus.granted);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final scannerState = ref.read(scannerProvider);
    if (scannerState.isPaused) return;
    if (capture.barcodes.isEmpty) return;
    if ((capture.barcodes.first.rawValue ?? '').isEmpty) return;

    ref.read(scannerProvider.notifier).pause();

    try {
      final record = await ref.read(scannerProvider.notifier).handleDetection(capture);

      if (!mounted) return;

      await Navigator.of(context).pushNamed(AppRoutes.result, arguments: record);

      // Resume scanning once the user comes back from the Result screen.
      ref.read(scannerProvider.notifier).resume();
    } catch (e) {
      ref.read(scannerProvider.notifier).setError('Could not process this code. Try again.');
      ref.read(scannerProvider.notifier).resume();
    }
  }

  void _toggleTorch() {
    _controller?.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildCameraLayer(),

            // Top bar: title + torch toggle
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_permissionStatus == _PermissionStatus.granted && _controller != null)
                    ValueListenableBuilder<TorchState>(
                      valueListenable: _controller!.torchState,
                      builder: (context, torchState, _) {
                        return TorchButton(
                          isOn: torchState == TorchState.on,
                          onPressed: _toggleTorch,
                        );
                      },
                    ),
                ],
              ),
            ),

            if (scannerState.errorMessage != null)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: _ErrorBanner(message: scannerState.errorMessage!),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildCameraLayer() {
    switch (_permissionStatus) {
      case _PermissionStatus.checking:
        return const Center(child: CircularProgressIndicator(color: Colors.white));

      case _PermissionStatus.denied:
        return _PermissionPrompt(
          message: 'Camera access is needed to scan codes.',
          buttonLabel: 'Grant permission',
          onPressed: _checkAndRequestPermission,
        );

      case _PermissionStatus.permanentlyDenied:
        return _PermissionPrompt(
          message:
              'Camera access was denied. Please enable it from your device settings to use the scanner.',
          buttonLabel: 'Open settings',
          onPressed: openAppSettings,
        );

      case _PermissionStatus.granted:
        return Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => _ScannerErrorView(error: error),
            ),
            ScanOverlay(isActive: !ref.watch(scannerProvider).isPaused),
          ],
        );
    }
  }
}

enum _PermissionStatus { checking, granted, denied, permanentlyDenied }

class _PermissionPrompt extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _PermissionPrompt({
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white54, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}

class _ScannerErrorView extends StatelessWidget {
  final MobileScannerException error;

  const _ScannerErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Camera unavailable. Please restart the app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}


