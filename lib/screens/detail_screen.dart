import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/reel_item.dart';
import '../providers/reel_provider.dart';
import '../constants/app_theme.dart';

class DetailScreen extends StatelessWidget {
  final ReelItem reel;

  const DetailScreen({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReelProvider>();
    final currentReel = provider.reels.firstWhere(
      (item) => item.id == reel.id,
      orElse: () => reel,
    );

    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppThemeConstants.backgroundColor,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: DotGridOverlay(),
              ),
            ),
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, currentReel, displayFont),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlatformBadge(currentReel, spaceFont),
                        const SizedBox(height: 12),
                        _buildTitle(currentReel, displayFont),
                        const SizedBox(height: 24),
                        
                        if (currentReel.caption.isNotEmpty) 
                          _buildCaptionSection(currentReel, monoFont, spaceFont),
                          
                        const SizedBox(height: 24),
                        _buildActionButtons(context, currentReel, displayFont),
                        const SizedBox(height: 32),

                        if (currentReel.isGenerating)
                          Container(
                            decoration: BoxDecoration(
                              color: AppThemeConstants.surfaceColor,
                              border: Border.all(color: AppThemeConstants.primaryColor, width: 4),
                              boxShadow: AppThemeConstants.neoShadowSm,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3, 
                                    color: AppThemeConstants.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'AI memory is being generated. It will appear here when ready.',
                                    style: monoFont.copyWith(fontSize: 13, color: AppThemeConstants.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (!currentReel.isGenerating && currentReel.aiMemory != null)
                          Container(
                            decoration: BoxDecoration(
                              color: AppThemeConstants.surfaceColor,
                              border: Border.all(color: AppThemeConstants.primaryColor, width: 4),
                              boxShadow: AppThemeConstants.neoShadow,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, color: AppThemeConstants.tertiaryFixed),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Why You Saved This',
                                      style: spaceFont.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppThemeConstants.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  currentReel.aiMemory!,
                                  style: monoFont.copyWith(fontSize: 14, color: AppThemeConstants.primaryColor, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 24),
                        if (currentReel.aiTags != null && currentReel.aiTags!.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: currentReel.aiTags!.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppThemeConstants.surfaceColor,
                                border: Border.all(color: AppThemeConstants.primaryColor, width: 2),
                              ),
                              child: Text(
                                tag.toUpperCase(),
                                style: monoFont.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppThemeConstants.primaryColor),
                              ),
                            )).toList(),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ReelItem currentReel, TextStyle displayFont) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppThemeConstants.surfaceColor,

      title: Text(
        'DETAILS',
        style: displayFont.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppThemeConstants.primaryColor,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: false,

      shape: const Border(
        bottom: BorderSide(
          color: AppThemeConstants.primaryColor,
          width: 6,
        ),
      ),

      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeConstants.surfaceColor,
              border: Border.all(
                color: AppThemeConstants.primaryColor,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppThemeConstants.primaryColor,
            ),
          ),
        ),
      ),

      flexibleSpace: FlexibleSpaceBar(
        background: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: currentReel.thumbnailUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: currentReel.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppThemeConstants.surfaceContainerLow),
                  errorWidget: (context, url, error) => _thumbnailPlaceholder(),
                )
              : _thumbnailPlaceholder(),
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: AppThemeConstants.surfaceContainerLow,
      child: const Icon(Icons.video_library, size: 60, color: AppThemeConstants.primaryColor),
    );
  }

  Widget _buildPlatformBadge(ReelItem currentReel, TextStyle spaceFont) {
    final isInstagram = currentReel.platform == 'instagram';
    final badgeColor = isInstagram ? AppThemeConstants.tertiaryFixed : AppThemeConstants.errorColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        border: Border.all(color: AppThemeConstants.primaryColor, width: 2),
      ),
      child: Text(
        isInstagram ? '📸 INSTAGRAM' : '▶️ YOUTUBE',
        style: spaceFont.copyWith(
          color: isInstagram ? AppThemeConstants.primaryColor : AppThemeConstants.surfaceColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTitle(ReelItem currentReel, TextStyle displayFont) {
    return Text(
      currentReel.title.isNotEmpty ? currentReel.title.toUpperCase() : 'NO_TITLE_AVAILABLE',
      style: displayFont.copyWith(fontSize: 28, color: AppThemeConstants.primaryColor, letterSpacing: -0.5),
    );
  }

  Widget _buildCaptionSection(ReelItem currentReel, TextStyle monoFont, TextStyle spaceFont) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📝 CAPTION',
          style: spaceFont.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: AppThemeConstants.primaryColor),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppThemeConstants.surfaceContainerLow,
            border: Border.all(color: AppThemeConstants.primaryColor, width: 2),
          ),
          child: Text(
            currentReel.caption,
            style: monoFont.copyWith(
              fontSize: 13,
              color: AppThemeConstants.primaryColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ReelItem currentReel, TextStyle displayFont) {
    final provider = context.read<ReelProvider>();

    return Column(
      children: [
        // --- Open Original Button ---
        NeoBrutalistInteractiveButton(
          onPressed: () => _openUrl(context),
          backgroundColor: AppThemeConstants.surfaceColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_new, color: AppThemeConstants.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'OPEN ORIGINAL',
                  style: displayFont.copyWith(fontSize: 20, color: AppThemeConstants.primaryColor, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        NeoBrutalistInteractiveButton(
          onPressed: () async {
            final wasReviewed = currentReel.isReviewed;

            await provider.toggleReviewed(currentReel);

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  wasReviewed
                      ? 'Marked as unreviewed ↩️'
                      : 'Marked as reviewed ✅',
                  style: GoogleFonts.jetBrainsMono(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
          backgroundColor: currentReel.isReviewed
              ? AppThemeConstants.tertiaryFixed
              : AppThemeConstants.secondaryFixed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentReel.isReviewed
                      ? Icons.undo
                      : Icons.check_circle_outline,
                  color: AppThemeConstants.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  currentReel.isReviewed
                      ? 'MARK AS UNREVIEWED'
                      : 'MARK AS REVIEWED',
                  style: displayFont.copyWith(
                    fontSize: 20,
                    color: AppThemeConstants.primaryColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.parse(reel.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
      }
    }
  }
}

// --- Stateful Interactive Mechanical Layout Accent Button Container ---

class NeoBrutalistInteractiveButton extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const NeoBrutalistInteractiveButton({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  State<NeoBrutalistInteractiveButton> createState() => _NeoBrutalistInteractiveButtonState();
}

class _NeoBrutalistInteractiveButtonState extends State<NeoBrutalistInteractiveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: _isPressed
            ? Matrix4.translationValues(4, 4, 0)
            : Matrix4.translationValues(0, 0, 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(color: AppThemeConstants.primaryColor, width: 4),
          boxShadow: _isPressed
              ? const [
                  BoxShadow(
                    color: AppThemeConstants.primaryColor,
                    offset: Offset(2, 2),
                  )
                ]
              : AppThemeConstants.neoShadow,
        ),
        child: widget.child,
      ),
    );
  }
}

// --- Canvas Alignment Helpers ---

class DotGridOverlay extends StatelessWidget {
  const DotGridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotGridPainter(),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppThemeConstants.primaryColor.withValues(alpha: 0.06)
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