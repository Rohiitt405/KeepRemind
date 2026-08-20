import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/saved_link_provider.dart';
import '../constants/app_theme.dart';
import '../exceptions/backup_exception.dart';
import '../models/backup_result.dart';
import '../models/restore_result.dart';
import '../services/backup_service.dart';
import '../widgets/shared/dot_grid_overlay.dart';
import '../widgets/shared/neo_brutalist_button.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();

  bool _isBackingUp = false;
  bool _isRestoring = false;

  static const Color primaryColor = AppThemeConstants.primaryColor;
  static const Color backgroundColor = AppThemeConstants.backgroundColor;
  static const Color tertiaryFixed = AppThemeConstants.tertiaryFixed;
  static const Color secondaryFixed = AppThemeConstants.secondaryFixed;
  static const Color surfaceColor = AppThemeConstants.surfaceColor;

  Future<void> _backupData() async {
    if (_isBackingUp || _isRestoring) return;

    setState(() {
      _isBackingUp = true;
    });

    try {
      final BackupResult result =
          await _backupService.createBackup();

      if (!mounted || result.cancelled) {
        return;
      }

      _showSuccessMessage(
        'SUCCESS: ${result.totalItems} ITEMS_EXPORTED',
      );
    } on BackupException catch (e) {
      if (mounted) {
        _showErrorMessage(
          'BACKUP_ERR: ${e.message}',
        );
      }
    } catch (_) {
      if (mounted) {
        _showErrorMessage(
          'BACKUP_ERR: EXPORT_FAILED',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  Future<void> _restoreData() async {
    if (_isBackingUp || _isRestoring) return;

    setState(() {
      _isRestoring = true;
    });

    try {
      final RestoreResult result =
          await _backupService.restoreBackup();

      if (!mounted || result.cancelled) {
        return;
      }

      context.read<SavedLinkProvider>().refreshSavedLinks();

      await _showRestoreResult(result);
    } on BackupException catch (e) {
      if (mounted) {
        _showErrorMessage(
          'RESTORE_ERR: ${e.message}',
        );
      }
    } catch (_) {
      if (mounted) {
        _showErrorMessage(
          'RESTORE_ERR: IMPORT_FAILED',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  Future<void> _showRestoreResult(
    RestoreResult result,
  ) async {
    final monoFont = GoogleFonts.jetBrainsMono();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: primaryColor,
              width: 4,
            ),
          ),
          title: Text(
            'RESTORE_STATUS',
            style: monoFont.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'RESTORE COMPLETE\n\n'
            'RESTORED: ${result.restoredItems}\n'
            'DUPLICATES: ${result.duplicateItems}\n'
            'SKIPPED: ${result.skippedItems}',
            style: monoFont.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: primaryColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  'CLOSE',
                  style: monoFont.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: primaryColor,
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            color: tertiaryFixed,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppThemeConstants.quarterFixed,
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(
            color: primaryColor,
            width: 6,
          ),
        ),
        title: Text(
          'DATA',
          style: displayFont.copyWith(
            fontSize: 28,
            color: primaryColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: DotGridOverlay(),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      border: Border.all(
                        color: primaryColor,
                        width: 4,
                      ),
                      boxShadow:
                          AppThemeConstants.neoShadow,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '[DATA_MANAGEMENT]',
                          style: monoFont.copyWith(
                            fontSize: 18,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            backgroundColor:
                                secondaryFixed,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'BACK UP YOUR SAVED CONTENT TO A LOCAL FILE OR RESTORE CONTENT FROM A PREVIOUS BACKUP.',
                          style: monoFont.copyWith(
                            fontSize: 11,
                            color: AppThemeConstants
                                .onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  _buildActionCard(
                    title: 'BACKUP_DATA',
                    description:
                        'EXPORT YOUR CURRENT SAVED CONTENT AS A KEEPREMIND BACKUP FILE.',
                    icon: Icons.download_rounded,
                    backgroundColor: tertiaryFixed,
                    enabled:
                        !_isBackingUp &&
                        !_isRestoring,
                    loading: _isBackingUp,
                    onPressed: _backupData,
                    displayFont: displayFont,
                    monoFont: monoFont,
                    spaceFont: spaceFont,
                  ),

                  const SizedBox(height: 24),

                  _buildActionCard(
                    title: 'RESTORE_DATA',
                    description:
                        'IMPORT SAVED CONTENT FROM A PREVIOUS KEEPREMIND BACKUP.',
                    icon: Icons.restore_rounded,
                    backgroundColor: secondaryFixed,
                    enabled:
                        !_isBackingUp &&
                        !_isRestoring,
                    loading: _isRestoring,
                    onPressed: _restoreData,
                    displayFont: displayFont,
                    monoFont: monoFont,
                    spaceFont: spaceFont,
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      border: Border.all(
                        color: primaryColor,
                        width: 3,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'RESTORE DOES NOT DELETE YOUR EXISTING DATA. DUPLICATE LINKS ARE SKIPPED AUTOMATICALLY.',
                            style: monoFont.copyWith(
                              fontSize: 10,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
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
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color backgroundColor,
    required bool enabled,
    required bool loading,
    required VoidCallback onPressed,
    required TextStyle displayFont,
    required TextStyle monoFont,
    required TextStyle spaceFont,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(
          color: primaryColor,
          width: 4,
        ),
        boxShadow: AppThemeConstants.neoShadow,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: backgroundColor,
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: spaceFont.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            description,
            style: monoFont.copyWith(
              fontSize: 10,
              color: AppThemeConstants
                  .onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          NeoBrutalistButton(
            onPressed:
                enabled ? onPressed : null,
            backgroundColor: backgroundColor,
            borderColor: primaryColor,
            shape: BoxShape.rectangle,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            enabled: enabled,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                        CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: primaryColor,
                    size: 22,
                  ),
                const SizedBox(width: 10),
                Text(
                  loading
                      ? 'PROCESSING...'
                      : title,
                  style: displayFont.copyWith(
                    fontSize: 22,
                    letterSpacing: 1.5,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}