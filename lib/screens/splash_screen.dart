import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../providers/reel_provider.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool skipDefaultNavigation;

  const SplashScreen({super.key, this.skipDefaultNavigation = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Neo-Brutalist Global Design Tokens
  static const Color primaryColor = AppThemeConstants.primaryColor;
  static const Color backgroundColor = AppThemeConstants.backgroundColor;
  static const Color tertiaryFixed = AppThemeConstants.tertiaryFixed;
  static const Color secondaryFixed = AppThemeConstants.secondaryFixed;
  static const Color quarterFixed = AppThemeConstants.quarterFixed;

  String _systemStatus = 'INITIALIZING_CORE...';
  double _loadProgress = 0.0;
  late Timer _progressTimer;

  List<BoxShadow> get neoShadow => AppThemeConstants.neoShadow;

  @override
  void initState() {
    super.initState();
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: backgroundColor,
    ));

    _startBootSequence();
  }

  void _startBootSequence() {
    // Artificial pipeline staging increments to mimic terminal execution load array strings
    const duration = Duration(milliseconds: 40);
    _progressTimer = Timer.periodic(duration, (timer) {
      if (!mounted) return;
      
      setState(() {
        _loadProgress += 0.02;
        
        if (_loadProgress >= 0.25 && _loadProgress < 0.60) {
          _systemStatus = 'TUNING_VISUAL_PROCESSORS...';
        } else if (_loadProgress >= 0.60 && _loadProgress < 0.85) {
          _systemStatus = 'MOUNTING_LOCAL_DATABASE...';
        } else if (_loadProgress >= 0.85 && _loadProgress < 1.0) {
          _systemStatus = 'ESTABLISHING_HANDSHAKE_PIPELINES...';
        } else if (_loadProgress >= 1.0) {
          _loadProgress = 1.0;
          _systemStatus = 'BOOT_SEQUENCE_COMPLETE';
          _progressTimer.cancel();
          _navigateToNextScreen();
        }
      });
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted || widget.skipDefaultNavigation) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;

    if (onboardingDone) {
      final provider = context.read<ReelProvider>();
      await provider.ensureInitialDataLoaded();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => onboardingDone ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _progressTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Canvas Alignment Dot Mesh Overlay
          const Positioned.fill(
            child: IgnorePointer(
              child: DotGridOverlay(),
            ),
          ),

          // Central Geometric Logo Anchor Grid
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Outer Industrial Monolithic Frame Asset
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor, width: 6),
                      boxShadow: neoShadow,
                    ),
                    child: Column(
                      children: [
                        // Stylized Mechanical App Badge Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: quarterFixed,
                                border: Border.all(color: primaryColor, width: 2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: secondaryFixed,
                                border: Border.all(color: primaryColor, width: 2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: tertiaryFixed,
                                border: Border.all(color: primaryColor, width: 2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Bold Brand Core Title Header
                        Text(
                          'KEEP REMIND',
                          style: displayFont.copyWith(
                            fontSize: 44,
                            color: primaryColor,
                            letterSpacing: -0.5,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // --- Central Processing Progress Bar Interface ---
                  Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: primaryColor, width: 4),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 40),
                                    width: constraints.maxWidth * _loadProgress,
                                    color: secondaryFixed,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CORE_LOADING_BUFFER',
                              style: spaceFont.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              '${(_loadProgress * 100).toInt()}%',
                              style: monoFont.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: primaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '>> $_systemStatus',
                      style: monoFont.copyWith(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: tertiaryFixed,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- Canvas Architecture Mesh Painter ---

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