import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../constants/app_theme.dart';
import '../models/saved_link_model.dart';
import '../models/social_platform.dart';

class SavedLinkCard extends StatelessWidget {
  final SavedLink savedLink;
  final VoidCallback onTap;

  const SavedLinkCard({
    super.key,
    required this.savedLink,
    required this.onTap,
  });

  static const Color primaryColor = AppThemeConstants.primaryColor;
  static const Color surfaceWhite = AppThemeConstants.surfaceColor;
  static const Color surfaceContainerLow =
      AppThemeConstants.surfaceContainerLow;
  static const Color tertiaryFixed = AppThemeConstants.tertiaryFixed;
  static const Color secondaryFixed = AppThemeConstants.secondaryFixed;
  static const Color quarterFixed = AppThemeConstants.quarterFixed;
  static const Color onSurfaceVariant = AppThemeConstants.onSurfaceVariant;

  static const List<BoxShadow> neoShadowSm = [
    BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    final badgeColor = savedLink.platform.color;

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
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: _buildThumbnail(),
                    ),

                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: badgeColor,
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
                      children: [
                        Expanded(
                          child: Text(
                            savedLink.title.isEmpty
                                ? "UNTITLED LINK"
                                : savedLink.title.toUpperCase(),
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

                        _buildPlatformBadge(spaceFont),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text(
                          "SAVED ${_formatDate(savedLink.savedAt).toUpperCase()}",
                          style: spaceFont.copyWith(
                            fontSize: 10,
                            color: onSurfaceVariant,
                            fontWeight: FontWeight.bold,
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

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: surfaceContainerLow,
                        border: Border(
                          left: BorderSide(color: primaryColor, width: 4),
                        ),
                      ),
                      child: Text(
                        _memoryText(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: monoFont.copyWith(
                          fontSize: 11,
                          height: 1.3,
                          color: primaryColor,
                        ),
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
    if (savedLink.thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: savedLink.thumbnailUrl,
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
      child: Center(
        child: savedLink.platform.iconWidget,
      ),
    );
  }

  String _memoryText() {
    if (savedLink.isGenerating) {
      return "Generating AI summary...";
    }

    if (savedLink.aiMemory?.isNotEmpty == true) {
      return savedLink.aiMemory!;
    }

    return "No AI summary available.";
  }

  Widget _buildPlatformBadge(TextStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: savedLink.platform.color,
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: Text(
        savedLink.platform.label,
        style: style.copyWith(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    if (diff < 7) return "$diff days ago";

    return "${date.day}/${date.month}/${date.year}";
  }
}
