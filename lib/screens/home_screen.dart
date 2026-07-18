import 'package:flutter/material.dart';
import 'package:project/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import '../providers/reel_provider.dart';
import '../widgets/reel_card.dart';
import '../models/reel_item.dart';
import 'detail_screen.dart';
import 'add_url_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color primaryColor = Colors.black;
  static const Color backgroundColor = Color(0xFFF9F9F9);
  // static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color tertiaryFixed = Color(0xFF72FF70);
  static const Color secondaryFixed = Color(0xFFEAEA00);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color onSurfaceVariant = Color(0xFF4C4546);

  List<BoxShadow> get neoShadow => const [
        BoxShadow(
          color: Colors.black,
          offset: Offset(6, 6),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  List<BoxShadow> get neoShadowSm => const [
        BoxShadow(
          color: Colors.black,
          offset: Offset(4, 4),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReelProvider>();
    
    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
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
                fontSize: 28,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                child: const Icon(Icons.menu_rounded, color: primaryColor, size: 22),
              ),
            )
          ],
        ),
        
        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: DotGridOverlay(),
              ),
            ),
            
            Column(
              children: [
                const SizedBox(height: 24),
                
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? secondaryFixed : Colors.transparent,
                              border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
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
                      _buildReelList(context, provider.reels, monoFont, spaceFont),
                      _buildReelList(context, provider.unreviewedReels, monoFont, spaceFont),
                      _buildReelList(context, provider.reviewedReels, monoFont, spaceFont),
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

  Widget _buildReelList(BuildContext context, List<ReelItem> reels, TextStyle monoFont, TextStyle spaceFont) {
    if (reels.isEmpty) {
      return _buildEmptyState(spaceFont, monoFont);
    }

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: reels.length,
        itemBuilder: (context, index) {
          final reel = reels[index];

          return Dismissible(
            key: Key(reel.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAD6),
                border: Border.all(color: errorColor, width: 4),
              ),
              child: const Icon(Icons.delete_forever_outlined, color: errorColor, size: 28),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (ctx) => _buildBrutalistDialog(ctx, 'DELETE DATA SEGMENT?', spaceFont, monoFont),
              );
            },
            onDismissed: (_) {
              context.read<ReelProvider>().deleteReel(reel.id);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ReelCard(
                reel: reel,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(reel: reel)),
                ),
                onDelete: () => _confirmDelete(context, reel.id, spaceFont, monoFont),
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
          color: Colors.white,
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

  Widget _buildBrutalistDialog(BuildContext context, String title, TextStyle spaceFont, TextStyle monoFont) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      titlePadding: const EdgeInsets.all(20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actionsPadding: const EdgeInsets.all(16),
      iconPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black,
        child: Text(
          title,
          style: spaceFont.copyWith(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      content: Container(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          'This modification cannot be reverted in the system core library.',
          style: monoFont.copyWith(color: primaryColor, fontSize: 14, height: 1.3),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pop(context, false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: primaryColor, width: 2)),
            child: Text('Cancel', style: spaceFont.copyWith(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pop(context, true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: errorColor,
            child: Text('DELETE', style: spaceFont.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, String reelId, TextStyle spaceFont, TextStyle monoFont) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildBrutalistDialog(ctx, 'DELETE RECORD?', spaceFont, monoFont),
    );

    if (confirmed == true) {
      if (mounted) context.read<ReelProvider>().deleteReel(reelId);
    }
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
  State<NeoFloatingActionButton> createState() => _NeoFloatingActionButtonState();
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
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: _isPressed
              ? const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                  )
                ]
              : const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(6, 6),
                  )
                ],
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
    );
  }
}


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
      ..color = Colors.black.withOpacity(0.06)
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