import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';

class ShareLoadingScreen extends StatelessWidget {
  final String? initialUrl;

  const ShareLoadingScreen({super.key, this.initialUrl});

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    return Scaffold(
      backgroundColor: AppThemeConstants.backgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: DotGridOverlay())),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppThemeConstants.surfaceColor,
                  border: Border.all(color: AppThemeConstants.primaryColor, width: 4),
                  boxShadow: AppThemeConstants.neoShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREPARING SHARE LINK',
                      style: displayFont.copyWith(
                        fontSize: 28,
                        color: AppThemeConstants.primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Collecting your shared content and opening the editor…',
                      style: spaceFont.copyWith(
                        fontSize: 15,
                        color: AppThemeConstants.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSkeletonRow(monoFont),
                    const SizedBox(height: 12),
                    _buildSkeletonRow(monoFont),
                    const SizedBox(height: 12),
                    _buildSkeletonBar(monoFont),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppThemeConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Waiting for link data…',
                          style: monoFont.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppThemeConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (initialUrl != null && initialUrl!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppThemeConstants.secondaryFixed,
                          border: Border.all(color: AppThemeConstants.primaryColor, width: 2),
                        ),
                        child: Text(
                          'Received: $initialUrl',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: monoFont.copyWith(fontSize: 12, color: AppThemeConstants.primaryColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonRow(TextStyle monoFont) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 12,
          color: const Color(0xFFEAEAEA),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppThemeConstants.surfaceContainerLow,
              border: Border.all(color: AppThemeConstants.primaryColor, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonBar(TextStyle monoFont) {
    return Container(
      height: 14,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeConstants.surfaceContainerLow,
        border: Border.all(color: AppThemeConstants.primaryColor, width: 2),
      ),
    );
  }
}

class DotGridOverlay extends StatelessWidget {
  const DotGridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter());
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const double spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
