import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/social_platform.dart';
import '../models/saved_link_model.dart';
import '../providers/saved_link_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/shared/dot_grid_overlay.dart';
import '../widgets/shared/neo_brutalist_button.dart';

class DetailScreen extends StatelessWidget {
  final SavedLink savedLink;

  const DetailScreen({super.key, required this.savedLink});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedLinkProvider>();
    final currentSavedLink = provider.savedLinks.firstWhere(
      (item) => item.id == savedLink.id,
      orElse: () => savedLink,
    );

    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(scaffoldBackgroundColor: AppThemeConstants.backgroundColor),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: DotGridOverlay()),
            ),
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, currentSavedLink, displayFont),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlatformBadge(currentSavedLink, spaceFont),
                        const SizedBox(height: 12),
                        _buildTitle(currentSavedLink, displayFont),
                        const SizedBox(height: 24),

                        if (currentSavedLink.caption.isNotEmpty)
                          _buildCaptionSection(
                            currentSavedLink,
                            monoFont,
                            spaceFont,
                          ),

                        const SizedBox(height: 24),
                        _buildActionButtons(
                          context,
                          currentSavedLink,
                          displayFont,
                        ),
                        const SizedBox(height: 32),

                        if (currentSavedLink.isGenerating)
                          Container(
                            decoration: BoxDecoration(
                              color: AppThemeConstants.surfaceColor,
                              border: Border.all(
                                color: AppThemeConstants.primaryColor,
                                width: 4,
                              ),
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
                                    style: monoFont.copyWith(
                                      fontSize: 13,
                                      color: AppThemeConstants.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (!currentSavedLink.isGenerating &&
                            currentSavedLink.aiMemory != null)
                          Container(
                            decoration: BoxDecoration(
                              color: AppThemeConstants.surfaceColor,
                              border: Border.all(
                                color: AppThemeConstants.primaryColor,
                                width: 4,
                              ),
                              boxShadow: AppThemeConstants.neoShadow,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      color: AppThemeConstants.tertiaryFixed,
                                    ),
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
                                  currentSavedLink.aiMemory!,
                                  style: monoFont.copyWith(
                                    fontSize: 14,
                                    color: AppThemeConstants.primaryColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),
                        if (currentSavedLink.aiTags != null &&
                            currentSavedLink.aiTags!.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: currentSavedLink.aiTags!
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppThemeConstants.surfaceColor,
                                      border: Border.all(
                                        color: AppThemeConstants.primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      tag.toUpperCase(),
                                      style: monoFont.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppThemeConstants.primaryColor,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
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

  Widget _buildSliverAppBar(
    BuildContext context,
    SavedLink currentSavedLink,
    TextStyle displayFont,
  ) {
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
        bottom: BorderSide(color: AppThemeConstants.primaryColor, width: 6),
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
          child: currentSavedLink.thumbnailUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: currentSavedLink.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: AppThemeConstants.surfaceContainerLow),
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
      child: const Icon(
        Icons.video_library,
        size: 60,
        color: AppThemeConstants.primaryColor,
      ),
    );
  }

  Widget _buildPlatformBadge(SavedLink currentSavedLink, TextStyle spaceFont) {
    final isInstagram = currentSavedLink.platform == SocialPlatform.instagram;
    final badgeColor = isInstagram
        ? AppThemeConstants.tertiaryFixed
        : AppThemeConstants.errorColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        border: Border.all(color: AppThemeConstants.primaryColor, width: 2),
      ),
      child: Text(
        isInstagram ? '📸 INSTAGRAM' : '▶️ YOUTUBE',
        style: spaceFont.copyWith(
          color: isInstagram
              ? AppThemeConstants.primaryColor
              : AppThemeConstants.surfaceColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTitle(SavedLink currentSavedLink, TextStyle displayFont) {
    return Text(
      currentSavedLink.title.isNotEmpty
          ? currentSavedLink.title.toUpperCase()
          : 'NO_TITLE_AVAILABLE',
      style: displayFont.copyWith(
        fontSize: 28,
        color: AppThemeConstants.primaryColor,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildCaptionSection(
    SavedLink currentSavedLink,
    TextStyle monoFont,
    TextStyle spaceFont,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📝 CAPTION',
          style: spaceFont.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppThemeConstants.primaryColor,
          ),
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
            currentSavedLink.caption,
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

  Widget _buildActionButtons(
    BuildContext context,
    SavedLink currentSavedLink,
    TextStyle displayFont,
  ) {
    final provider = context.read<SavedLinkProvider>();

    return Column(
      children: [
        NeoBrutalistButton(
          onPressed: () => _openUrl(context),
          backgroundColor: AppThemeConstants.surfaceColor,
          borderColor: AppThemeConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.open_in_new,
                color: AppThemeConstants.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'OPEN ORIGINAL',
                style: displayFont.copyWith(
                  fontSize: 20,
                  color: AppThemeConstants.primaryColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        NeoBrutalistButton(
          onPressed: () async {
            final wasReviewed = currentSavedLink.isReviewed;

            await provider.toggleReviewed(currentSavedLink);

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  wasReviewed
                      ? 'Marked as unreviewed ↩️'
                      : 'Marked as reviewed ✅',
                  style: GoogleFonts.jetBrainsMono(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
          backgroundColor: currentSavedLink.isReviewed
              ? AppThemeConstants.tertiaryFixed
              : AppThemeConstants.secondaryFixed,
          borderColor: AppThemeConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                currentSavedLink.isReviewed
                    ? Icons.undo
                    : Icons.check_circle_outline,
                color: AppThemeConstants.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                currentSavedLink.isReviewed
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
      ],
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.parse(savedLink.url);
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