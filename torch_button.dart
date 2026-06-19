import 'package:flutter/material.dart';

/// Simple icon button that toggles flashlight on/off, with a filled
/// background so it stays visible against any camera feed.
class TorchButton extends StatelessWidget {
  final bool isOn;
  final VoidCallback onPressed;

  const TorchButton({
    super.key,
    required this.isOn,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.4),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(
          isOn ? Icons.flash_on : Icons.flash_off,
          color: isOn ? Colors.amber : Colors.white,
        ),
        onPressed: onPressed,
        tooltip: isOn ? 'Turn off flashlight' : 'Turn on flashlight',
      ),
    );
  }
}
