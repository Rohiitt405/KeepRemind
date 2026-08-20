import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/update_info.dart';
import '../constants/app_theme.dart';
import '../providers/update_provider.dart';
import 'shared/neo_brutalist_button.dart';

class UpdateDialog {
  const UpdateDialog._();

  static Future<void> show(BuildContext context, UpdateInfo updateInfo) async {
    if (!context.mounted) return;

    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppThemeConstants.surfaceColor,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeConstants.surfaceColor,
              border: Border.all(
                color: AppThemeConstants.primaryColor,
                width: 4,
              ),
              boxShadow: AppThemeConstants.neoShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: AppThemeConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.system_update_alt_rounded,
                        color: AppThemeConstants.tertiaryFixed,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'SYSTEM_UPDATE_AVAILABLE',
                          style: displayFont.copyWith(
                            color: AppThemeConstants.surfaceColor,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Version Comparison Matrix
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppThemeConstants.surfaceContainerLow,
                          border: Border.all(
                            color: AppThemeConstants.primaryColor,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CURRENT_VER:',
                                  style: spaceFont.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemeConstants.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  updateInfo.currentVersion,
                                  style: monoFont.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemeConstants.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 1,
                              color: AppThemeConstants.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TARGET_VER:',
                                  style: spaceFont.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemeConstants.onSurfaceVariant,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  color: AppThemeConstants.tertiaryFixed,
                                  child: Text(
                                    updateInfo.latestVersion,
                                    style: monoFont.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemeConstants.onTertiaryFixed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // What's New Header
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            color: AppThemeConstants.secondaryFixed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "WHAT'S NEW",
                            style: spaceFont.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: AppThemeConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Release Notes Container
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppThemeConstants.surfaceContainerLowest,
                          border: Border(
                            left: BorderSide(
                              color: AppThemeConstants.primaryColor,
                              width: 4,
                            ),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            updateInfo.releaseNotes.isEmpty
                                ? "Bug fixes and performance improvements"
                                : updateInfo.releaseNotes,
                            style: monoFont.copyWith(
                              fontSize: 12,
                              color: AppThemeConstants.primaryColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final updateProvider = context.read<UpdateProvider>();

                                await updateProvider.skipCurrentUpdate();

                                if(dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppThemeConstants.surfaceColor,
                                  border: Border.all(
                                    color: AppThemeConstants.primaryColor,
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'SKIP VERSION',
                                    style: spaceFont.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemeConstants.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            flex: 2,
                            child: NeoBrutalistButton(
                              onPressed: () async {
                                final url = updateInfo.downloadUrl.isNotEmpty
                                    ? updateInfo.downloadUrl
                                    : updateInfo.releasePageUrl;

                                final uri = Uri.parse(url);

                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              backgroundColor: AppThemeConstants.secondaryFixed,
                              borderColor: AppThemeConstants.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.download_rounded,
                                    color: AppThemeConstants.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'UPDATE NOW',
                                    style: displayFont.copyWith(
                                      fontSize: 18,
                                      letterSpacing: 0.5,
                                      color: AppThemeConstants.primaryColor,
                                    ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}