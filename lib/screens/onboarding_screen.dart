import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  // Mark onboarding as seen and go to home

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const primaryColor = Color(0xFFFF2D78);
  static const secondaryColor = Color(0xFF00F0FF);
  static const tertiaryColor = Color(0xFF00FF9F);
  static const surfaceContainerColor = Color(0xFF141417);
  static const surfaceLowColor = Color(0xFF111114);
  static const onSurfaceColor = Color(0xFFE4E4E7);
  static const onSurfaceVariantColor = Color(0xFFA1A1AA);
  static const outlineColor = Color(0xFF3F3F46);

  double _alertOpacity = 1.0;
  double _visualOpacity = 1.0;
  double _summaryOpacity = 1.0;
  late Timer _flickerTimer;

  Future<void> _finish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
  
  @override
  void initState() {
    super.initState();
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Makes status bar background transparent
    statusBarIconBrightness: Brightness.light, // Forces white icons (time, battery) over dark background
    systemNavigationBarColor: Color(0xFF050505), // Matches your app's background color
  ));

    // Throttle the glitch frequency from 100ms down to 800ms to save CPU cycles
    _flickerTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (math.Random().nextDouble() > 0.85) {
        final targetModule = math.Random().nextInt(3);
        if (!mounted) return;
        setState(() {
          if (targetModule == 0) _alertOpacity = 0.7;
          if (targetModule == 1) _visualOpacity = 0.7;
          if (targetModule == 2) _summaryOpacity = 0.7;
        });
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) {
            setState(() {
              _alertOpacity = 1.0;
              _visualOpacity = 1.0;
              _summaryOpacity = 1.0;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _flickerTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soraFont = GoogleFonts.sora();
    final monoFont = GoogleFonts.jetBrainsMono();

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // Background grid remains full screen
          const Positioned.fill(
            child: RepaintBoundary(
              child: ScanlineOverlay(),
            ),
          ),

          // REMOVED SafeArea HERE - Layout now flows directly underneath the notification bar
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  // OPTIMIZATION: Increased height slightly to accommodate the status bar padding natively
                  expandedHeight: 70, 
                  backgroundColor: surfaceContainerColor.withValues(alpha: 0.8),
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                  title: Padding(
                    // Pushes title down slightly so it doesn't collide with the status bar icons
                    padding: const EdgeInsets.only(top: 12.0), 
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                          ),
                          child: const Icon(Icons.apps, color: primaryColor, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'REEL REMIND',
                          style: soraFont.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24), // Balanced internal body padding
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. System Alert Headline
                              AnimatedOpacity(
                                opacity: _alertOpacity,
                                duration: const Duration(milliseconds: 30),
                                child: CustomModuleBorder(
                                  color: primaryColor,
                                  child: Container(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '[ SYSTEM_ALERT ]',
                                              style: monoFont.copyWith(
                                                  fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold, letterSpacing: 2),
                                            ),
                                            Text(
                                              'ID: 08-X92',
                                              style: monoFont.copyWith(fontSize: 10, color: primaryColor.withValues(alpha: 0.5)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'STOP REWATCHING.',
                                          style: soraFont.copyWith(fontSize: 24, color: primaryColor, fontWeight: FontWeight.bold, height: 1.1),
                                        ),
                                        Text(
                                          'START REMEMBERING.',
                                          style: soraFont.copyWith(fontSize: 24, color: tertiaryColor, fontWeight: FontWeight.bold, height: 1.1),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(height: 1, color: primaryColor.withValues(alpha: 0.3)),
                                        const SizedBox(height: 8),
                                        const Row(
                                          children: [
                                            PingDot(),
                                            SizedBox(width: 8),
                                            StaticDot(opacity: 0.4),
                                            SizedBox(width: 8),
                                            StaticDot(opacity: 0.2),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 2. Visualization Module
                              AnimatedOpacity(
                                opacity: _visualOpacity,
                                duration: const Duration(milliseconds: 30),
                                child: CustomModuleBorder(
                                  color: primaryColor,
                                  child: Container(
                                    color: surfaceContainerColor,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withValues(alpha: 0.2),
                                            border: Border(bottom: BorderSide(color: primaryColor.withValues(alpha: 0.3))),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Visual_Processor_V1.0', style: monoFont.copyWith(fontSize: 10, color: primaryColor)),
                                              Row(
                                                children: [
                                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                                                  const SizedBox(width: 4),
                                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: secondaryColor, shape: BoxShape.circle)),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        AspectRatio(
                                          aspectRatio: 1,
                                          child: Stack(
                                            children: [
                                              // OPTIMIZATION: Replaced dynamic matrix calculation color-filter with blendMode
                                              Positioned.fill(
                                                child: Image.asset(
                                                  'assets/icons/NewAppIcon.png',
                                                  fit: BoxFit.cover,
                                                  color: Colors.black,
                                                  colorBlendMode: BlendMode.saturation,
                                                  opacity: const AlwaysStoppedAnimation(0.6),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.bottomCenter,
                                                      end: Alignment.topCenter,
                                                      colors: [surfaceContainerColor.withValues(alpha: 0.9), Colors.transparent],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 16,
                                                left: 16,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  color: surfaceContainerColor.withValues(alpha: 0.6),
                                                  child: Text(
                                                    'ANALYZING_BUFFER... 84%',
                                                    style: monoFont.copyWith(fontSize: 8, color: secondaryColor),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 3. Data Summary Module
                              AnimatedOpacity(
                                opacity: _summaryOpacity,
                                duration: const Duration(milliseconds: 30),
                                child: CustomModuleBorder(
                                  color: primaryColor,
                                  child: Container(
                                    color: surfaceLowColor,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.memory, color: secondaryColor, size: 18),
                                            const SizedBox(width: 8),
                                            Text('Core_Functions', style: monoFont.copyWith(fontSize: 10, color: secondaryColor, letterSpacing: 2)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.only(left: 12),
                                        decoration: const BoxDecoration(
                                          border: Border(left: BorderSide(color: secondaryColor, width: 2)),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            style: monoFont.copyWith(fontSize: 14, color: onSurfaceColor, height: 1.5),
                                            children: [
                                              const TextSpan(text: 'The ultimate memory tool for your saved Reels & Shorts. '),
                                              TextSpan(
                                                text: 'AI-powered takeaways',
                                                style: monoFont.copyWith(
                                                  color: tertiaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  backgroundColor: tertiaryColor.withValues(alpha: 0.1),
                                                ),
                                              ),
                                              const TextSpan(text: ', no rewatching required.'),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 4. Action Button Module
                            OutlinedButton(
                              onPressed: () => _finish(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: primaryColor),
                                padding: const EdgeInsets.all(16),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                backgroundColor: primaryColor.withValues(alpha: 0.1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Initialize_System',
                                    style: soraFont.copyWith(fontSize: 16, color: primaryColor, fontWeight: FontWeight.bold, letterSpacing: 2),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.login, color: primaryColor),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 5. Grid Data Modules (OPTIMIZATION: Changed layout architecture to row wraps)
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 110,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(border: Border.all(color: outlineColor.withValues(alpha: 0.3))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text('FEATURE: RECAP', style: monoFont.copyWith(fontSize: 8, color: secondaryColor), overflow: TextOverflow.ellipsis)),
                                            const PulseDot(),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Expanded(
                                          child: Text(
                                            'AI-distilled summaries of your saved reels.',
                                            style: monoFont.copyWith(fontSize: 9, color: onSurfaceVariantColor),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 110,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(border: Border.all(color: outlineColor.withValues(alpha: 0.3))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('MOD_02', style: monoFont.copyWith(fontSize: 8, color: onSurfaceVariantColor)),
                                        Text('SMART SEARCH', style: monoFont.copyWith(fontSize: 10, color: onSurfaceColor, fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Container(
                                          height: 4,
                                          color: surfaceContainerColor,
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(widthFactor: 0.5, child: Container(color: tertiaryColor)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 110,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(border: Border.all(color: outlineColor.withValues(alpha: 0.3))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('MOD_03', style: monoFont.copyWith(fontSize: 8, color: onSurfaceVariantColor)),
                                        Text('INSTANT SYNC', style: monoFont.copyWith(fontSize: 10, color: onSurfaceColor, fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Container(
                                          height: 4,
                                          color: surfaceContainerColor,
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(widthFactor: 0.75, child: Container(color: primaryColor)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 110,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(border: Border.all(color: outlineColor.withValues(alpha: 0.3))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('MOD_04', style: monoFont.copyWith(fontSize: 8, color: onSurfaceVariantColor)),
                                        Text('AI INSIGHTS', style: monoFont.copyWith(fontSize: 10, color: onSurfaceColor, fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        
                                        Container(
                                          height: 4,
                                          color: surfaceContainerColor,
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(widthFactor: 1.0, child: LoadingBarPulse()),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Footer Meta
                            Container(
                              padding: const EdgeInsets.only(top: 16),
                              decoration: BoxDecoration(border: Border(top: BorderSide(color: outlineColor.withValues(alpha: 0.2)))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('v4.0.2-NEON', style: monoFont.copyWith(fontSize: 10, color: onSurfaceVariantColor)),
                                  Text('LOCATION: TOKYO_GRID_7', style: monoFont.copyWith(fontSize: 10, color: onSurfaceVariantColor)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      )]
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Optimization Helpers & Painters ---

class CustomModuleBorder extends StatelessWidget {
  final Widget child;
  final Color color;

  const CustomModuleBorder({super.key, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerBracketPainter(color: color),
      child: Container(
        margin: const EdgeInsets.all(1),
        child: child,
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    const cornerSize = 8.0;
    canvas.drawLine(Offset.zero, const Offset(0, cornerSize), cornerPaint);
    canvas.drawLine(Offset.zero, const Offset(cornerSize, 0), cornerPaint);

    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerSize), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerSize, size.height), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanlineOverlay extends StatelessWidget {
  const ScanlineOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _TerminalGridPainter()),
    );
  }
}

class _TerminalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFFF2D78).withValues(alpha: 0.2)
      ..strokeWidth = 1;

    const step = 40.0; // Increased spacing slightly to reduce drawn line count
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PingDot extends StatefulWidget {
  const PingDot({super.key});
  @override
  State<PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<PingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 8 + (16 * _controller.value),
                height: 8 + (16 * _controller.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF2D78).withValues(alpha: 1.0 - _controller.value),
                ),
              ),
              Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF2D78))),
            ],
          );
        },
      ),
    );
  }
}

class StaticDot extends StatelessWidget {
  final double opacity;
  const StaticDot({super.key, required this.opacity});
  @override
  Widget build(BuildContext context) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF2D78).withOpacity(opacity)));
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({super.key});
  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 6, height: 6, color: const Color(0xFF00F0FF)),
    );
  }
}

class LoadingBarPulse extends StatefulWidget {
  const LoadingBarPulse({super.key});
  @override
  State<LoadingBarPulse> createState() => _LoadingBarPulseState();
}

class _LoadingBarPulseState extends State<LoadingBarPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _controller, child: Container(color: const Color(0xFF00F0FF)));
  }
}