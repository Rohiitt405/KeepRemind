import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backup_screen.dart';
import 'settings_screen.dart';
import 'detail_screen.dart';
import 'add_url_screen.dart';
import '../services/settings_service.dart';
import '../constants/app_theme.dart';
import '../providers/saved_link_provider.dart';
import '../providers/update_provider.dart';
import '../widgets/shared/dot_grid_overlay.dart';
import '../widgets/save_link_card.dart';
import '../widgets/update_dialog.dart';
import '../models/saved_link_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SettingsService _settingsService = SettingsService();

  static const Color primaryColor = AppThemeConstants.primaryColor;
  static const Color backgroundColor = AppThemeConstants.backgroundColor;
  static const Color tertiaryFixed = AppThemeConstants.tertiaryFixed;
  static const Color secondaryFixed = AppThemeConstants.secondaryFixed;
  static const Color quarterFixed = AppThemeConstants.quarterFixed;
  static const Color onSurfaceVariant = AppThemeConstants.onSurfaceVariant;

  List<BoxShadow> get neoShadowSm => AppThemeConstants.neoShadowSm;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdate();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkForAppUpdate() async {
    final shouldCheck = await _settingsService.shouldCheckForUpdate();

    if (!mounted || !shouldCheck) {
      return;
    }

    final updateProvider = context.read<UpdateProvider>();

    await updateProvider.checkForUpdate();
    await _settingsService.saveLastUpdateCheck(DateTime.now());

    if (!mounted) return;

    if (updateProvider.hasUpdate && updateProvider.updateInfo != null) {
      await UpdateDialog.show(context, updateProvider.updateInfo!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedLinkProvider>();

    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(scaffoldBackgroundColor: backgroundColor),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppThemeConstants.surfaceColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: const Border(
            bottom: BorderSide(color: primaryColor, width: 6),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              'KEEP REMIND',
              style: displayFont.copyWith(
                fontSize: 32,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          actions: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openEndDrawer(),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppThemeConstants.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),

        endDrawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.65,
          child: Drawer(
            backgroundColor: AppThemeConstants.surfaceColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppThemeConstants.surfaceContainerLowest,
                      border: Border(
                        bottom: BorderSide(
                          color: primaryColor,
                          width: 6,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        'MENU',
                        style: displayFont.copyWith(
                          fontSize: 30,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
          
                  const SizedBox(height: 16),
          
                  ListTile(
                    leading: const Icon(
                      Icons.schedule_rounded,
                      color: primaryColor,
                    ),
                    title: Text(
                      'SETTINGS',
                      style: spaceFont.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: primaryColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
          
                  ListTile(
                    leading: const Icon(
                      Icons.backup,
                      color: primaryColor,
                    ),
                    title: Text(
                      'BACKUP',
                      style: spaceFont.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: primaryColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BackupScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: DotGridOverlay()),
            ),

            Column(
              children: [
                const SizedBox(height: 24),

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppThemeConstants.surfaceColor,
                      border: Border.all(color: primaryColor, width: 4),
                      boxShadow: neoShadowSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final isSelected = _tabController.index == index;
                        String label = '';
                        if (index == 0) label = 'ALL';
                        if (index == 1) label = 'UNREVIEWED';
                        if (index == 2) label = 'REVIEWED';

                        return GestureDetector(
                          onTap: () => _tabController.animateTo(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? secondaryFixed
                                  : Colors.transparent,
                              border: isSelected
                                  ? Border.all(color: primaryColor, width: 2)
                                  : null,
                            ),
                            child: Text(
                              isSelected ? '[ $label ]' : label,
                              style: spaceFont.copyWith(
                                fontSize: 14,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSavedLinkList(
                        context,
                        provider.savedLinks,
                        monoFont,
                        spaceFont,
                      ),
                      _buildSavedLinkList(
                        context,
                        provider.unreviewedSavedLinks,
                        monoFont,
                        spaceFont,
                      ),
                      _buildSavedLinkList(
                        context,
                        provider.reviewedSavedLinks,
                        monoFont,
                        spaceFont,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        floatingActionButton: NeoFloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddUrlScreen()),
          ),
          accentColor: tertiaryFixed,
        ),
      ),
    );
  }

  Widget _buildSavedLinkList(
    BuildContext context,
    List<SavedLink> savedLinks,
    TextStyle monoFont,
    TextStyle spaceFont,
  ) {
    if (savedLinks.isEmpty) {
      return _buildEmptyState(spaceFont, monoFont);
    }

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: AppThemeConstants.surfaceColor,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: savedLinks.length,
        itemBuilder: (context, index) {
          final savedLink = savedLinks[index];

          return Dismissible(
            key: Key(savedLink.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAD6),
                border: Border.all(color: quarterFixed, width: 4),
              ),
              child: const Icon(
                Icons.delete_forever_outlined,
                color: quarterFixed,
                size: 28,
              ),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (ctx) => _buildBrutalistDialog(
                  ctx,
                  'DELETE DATA SEGMENT?',
                  spaceFont,
                  monoFont,
                ),
              );
            },
            onDismissed: (_) {
              context.read<SavedLinkProvider>().deleteSavedLink(savedLink.id);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SavedLinkCard(
                savedLink: savedLink,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(savedLink: savedLink),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(TextStyle spaceFont, TextStyle monoFont) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppThemeConstants.surfaceColor,
          border: Border.all(color: primaryColor, width: 4),
          boxShadow: neoShadowSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.terminal, size: 48, color: primaryColor),
            const SizedBox(height: 16),
            Text(
              'ARCHIVE_EMPTY_SEQUENCE',
              style: spaceFont.copyWith(
                fontSize: 14,
                color: primaryColor,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Execute prompt initialization (+)',
              style: monoFont.copyWith(fontSize: 12, color: onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrutalistDialog(
    BuildContext context,
    String title,
    TextStyle spaceFont,
    TextStyle monoFont,
  ) {
    return AlertDialog(
      backgroundColor: AppThemeConstants.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      titlePadding: const EdgeInsets.all(20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actionsPadding: const EdgeInsets.all(16),
      iconPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Container(
        padding: const EdgeInsets.all(8),
        color: AppThemeConstants.primaryColor,
        child: Text(
          title,
          style: spaceFont.copyWith(
            color: AppThemeConstants.surfaceColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Container(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          'This modification cannot be reverted in the system core library.',
          style: monoFont.copyWith(
            color: primaryColor,
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pop(context, false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 2),
            ),
            child: Text(
              'CANCEL',
              style: spaceFont.copyWith(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pop(context, true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: quarterFixed,
            child: Text(
              'DELETE',
              style: spaceFont.copyWith(
                color: AppThemeConstants.surfaceColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NeoFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color accentColor;

  const NeoFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.accentColor,
  });

  @override
  State<NeoFloatingActionButton> createState() =>
      _NeoFloatingActionButtonState();
}

class _NeoFloatingActionButtonState extends State<NeoFloatingActionButton> {
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
        width: 60,
        height: 60,
        transform: _isPressed
            ? Matrix4.translationValues(4, 4, 0)
            : Matrix4.translationValues(0, 0, 0),
        decoration: BoxDecoration(
          color: widget.accentColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppThemeConstants.primaryColor, width: 4),
          boxShadow: _isPressed
              ? [
                  const BoxShadow(
                    color: AppThemeConstants.primaryColor,
                    offset: Offset(2, 2),
                  ),
                ]
              : AppThemeConstants.neoShadow,
        ),
        child: const Icon(
          Icons.add,
          color: AppThemeConstants.primaryColor,
          size: 32,
        ),
      ),
    );
  }
}
