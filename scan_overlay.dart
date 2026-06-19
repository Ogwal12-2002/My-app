import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Paints the dark mask with a clear square cutout, white corner brackets,
/// and an animated horizontal line sweeping through the frame to signal
/// "actively scanning."
class ScanOverlay extends StatefulWidget {
  final bool isActive;

  const ScanOverlay({super.key, this.isActive = true});

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSize = constraints.maxWidth * 0.7;

        return Stack(
          children: [
            // Dark mask with cutout
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.overlayMask,
                BlendMode.srcOut,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: frameSize,
                      height: frameSize,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Corner brackets + animated scan line, centered over the cutout
            Center(
              child: SizedBox(
                width: frameSize,
                height: frameSize,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(frameSize, frameSize),
                      painter: _CornerBracketsPainter(),
                    ),
                    if (widget.isActive)
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return Positioned(
                            top: _controller.value * (frameSize - 4),
                            left: 12,
                            right: 12,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.scanLine,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.scanLine.withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double bracketLength = 28;
    const double strokeWidth = 4;
    const double radius = 24;

    final paint = Paint()
      ..color = AppColors.scanFrameBorder
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, bracketLength + radius)
        ..lineTo(0, radius)
        ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
        ..lineTo(bracketLength + radius, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - bracketLength - radius, 0)
        ..lineTo(size.width - radius, 0)
        ..arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius))
        ..lineTo(size.width, bracketLength + radius),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - bracketLength - radius)
        ..lineTo(0, size.height - radius)
        ..arcToPoint(Offset(radius, size.height), radius: const Radius.circular(radius))
        ..lineTo(bracketLength + radius, size.height),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - bracketLength - radius)
        ..lineTo(size.width, size.height - radius)
        ..arcToPoint(
          Offset(size.width - radius, size.height),
          radius: const Radius.circular(radius),
          clockwise: false,
        )
        ..lineTo(size.width - bracketLength - radius, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
