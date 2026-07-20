import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/constants/app_theme.dart';
import '../models/reel_item.dart';

class ReelCard extends StatelessWidget {
  final ReelItem reel;
  final VoidCallback onTap;

  const ReelCard({
    super.key,
    required this.reel,
    required this.onTap,
  });

  static const Color primaryColor = AppThemeConstants.primaryColor;
  static const Color surfaceWhite = AppThemeConstants.surfaceColor;
  static const Color surfaceContainerLow = AppThemeConstants.surfaceContainerLow;
  static const Color tertiaryFixed = AppThemeConstants.tertiaryFixed;
  static const Color secondaryFixed = AppThemeConstants.secondaryFixed;
  static const Color quarterFixed = AppThemeConstants.quarterFixed;
  static const Color onSurfaceVariant = AppThemeConstants.onSurfaceVariant;

  List<BoxShadow> get neoShadowSm => const [
        BoxShadow(
          color: Colors.black,
          offset: Offset(4, 4),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    final bool isInstagram = reel.platform == 'instagram';
    final Color platformAccent = isInstagram ? tertiaryFixed : secondaryFixed;

    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        border: Border.all(color: primaryColor, width: 4),
        boxShadow: neoShadowSm,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 110,
                decoration: BoxDecoration(
                  color: surfaceContainerLow,
                  border: Border.all(color: primaryColor, width: 3),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]), // Matches the technical web app's layout rules natively
                      child: _buildThumbnail(),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: platformAccent,
                          border: const Border(
                            bottom: BorderSide(color: primaryColor, width: 2),
                            right: BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            reel.title.isNotEmpty ? reel.title.toUpperCase() : 'UNTITLED_STREAM',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: monoFont.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPlatformBadge(isInstagram, spaceFont),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Text(
                          'SAVED_AT ${_formatDate(reel.savedAt)}'.toUpperCase(),
                          style: spaceFont.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: primaryColor.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: surfaceContainerLow,
                        border: Border(
                          left: BorderSide(color: primaryColor, width: 4),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                color: platformAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AI_TAKEAWAY_INSIGHT',
                                style: spaceFont.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.7,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getMemoryContext(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: monoFont.copyWith(
                              fontSize: 11,
                              height: 1.3,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (reel.thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: reel.thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _thumbnailPlaceholder(),
        errorWidget: (context, url, error) => _thumbnailPlaceholder(),
      );
    }
    return _thumbnailPlaceholder();
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: primaryColor,
      child: const Icon(Icons.video_library, color: surfaceWhite, size: 32),
    );
  }

  String _getMemoryContext() {
    if (reel.isGenerating) {
      return '🤖 ANALYZING_BUFFER... pending AI memory compilation.';
    }
    if (reel.aiMemory != null && reel.aiMemory!.isNotEmpty) {
      return reel.aiMemory!;
    }
    return 'No additional contextual metadata compiled.';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}.${date.month}.${date.year}';
  }

  Widget _buildPlatformBadge(bool isInstagram, TextStyle spaceFont) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isInstagram ? tertiaryFixed : quarterFixed,
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: Text(
        isInstagram ? 'INSTA' : 'YOUTUBE',
        style: spaceFont.copyWith(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}