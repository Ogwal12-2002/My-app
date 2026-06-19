import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../models/scan_record.dart';
import '../../providers/generator_provider.dart';
import '../../services/database_service.dart';
import '../../services/qr_generator_service.dart';
import '../../services/share_service.dart';
import '../../widgets/app_bottom_nav.dart';
import 'widgets/qr_preview.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  final _screenshotController = ScreenshotController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveImage() async {
    final state = ref.read(generatorProvider);
    if (!state.isValid) return;

    final bytes = await _screenshotController.capture();
    if (bytes == null) return;

    final file = await QrGeneratorService.saveImage(bytes);

    // Persist to history so generated codes show up alongside scans.
    await DatabaseService.instance.insert(
      ScanRecord(
        content: state.encodedValue,
        format: 'qrCode',
        type: state.mode == GeneratorMode.url
            ? ScanContentType.url
            : ScanContentType.text,
        scannedAt: DateTime.now(),
        isGenerated: true,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to ${file.path}')),
      );
    }
  }

  Future<void> _shareImage() async {
    final state = ref.read(generatorProvider);
    if (!state.isValid) return;

    final bytes = await _screenshotController.capture();
    if (bytes == null) return;

    final file = await QrGeneratorService.saveImage(bytes, fileName: 'qr_share.png');
    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generatorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR Code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SegmentedButton<GeneratorMode>(
                segments: const [
                  ButtonSegment(value: GeneratorMode.text, label: Text('Text')),
                  ButtonSegment(value: GeneratorMode.url, label: Text('URL')),
                ],
                selected: {state.mode},
                onSelectionChanged: (selection) {
                  ref.read(generatorProvider.notifier).setMode(selection.first);
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                maxLines: state.mode == GeneratorMode.text ? 4 : 1,
                keyboardType: state.mode == GeneratorMode.url
                    ? TextInputType.url
                    : TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: state.mode == GeneratorMode.url
                      ? 'example.com'
                      : 'Enter text to encode...',
                ),
                onChanged: (value) => ref.read(generatorProvider.notifier).setInput(value),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: QrPreview(
                    data: state.encodedValue,
                    controller: _screenshotController,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isValid ? _shareImage : null,
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isValid ? _saveImage : null,
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Save Image'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
