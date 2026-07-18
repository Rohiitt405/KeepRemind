import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class KeepRemindSplash extends StatefulWidget {
  const KeepRemindSplash({super.key});

  @override
  State<KeepRemindSplash> createState() => _KeepRemindSplashState();
}

class _KeepRemindSplashState extends State<KeepRemindSplash> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  
  // Timer progress tracking
  double _progress = 0.0;
  String _statusText = "Accessing...";
  Color _statusColor = const Color(0xFFE8E0F0).withValues(alpha: 0.3);
  Timer? _progressTimer;

  // Design Constants
  final Color _primaryColor = const Color(0xFFFF2D78);
  final Color _secondaryColor = const Color(0xFF00FFCC);
  final Color _backgroundColor = const Color.fromARGB(255, 0, 0, 0);
  final Color _onBackground = const Color(0xFFE8E0F0);

  @override
  void initState() {
    super.initState();

    // 1. Handle Entrance Animation (Fade & Scale)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: const Cubic(0.2, 0.8, 0.2, 1.0),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Cubic(0.2, 0.8, 0.2, 1.0)),
    );

    _fadeController.forward();

    // 2. Start the Progress Loader after an aesthetic 800ms delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _startProgressLoop();
    });
  }

  void _startProgressLoop() {
    final random = math.Random();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;

      setState(() {
        if (_progress <= 1.0) {
          // Dynamic status updates based on progress thresholds
          if (_progress < 0.20) {
            _statusText = "INITIALIZING";
          } else if (_progress < 0.50) {
            _statusText = "AUTHENTICATING";
          } else if (_progress < 0.80) {
            _statusText = "SYNCING VAULT";
          } else if (_progress < 1.0) {
            _statusText = "FINALIZING";
          }

          // Random step matching HTML script logic
          _progress += (random.nextDouble() * 0.008) + 0.001;
        } else {
          _progress = 1.0;
          _statusText = "READY";
          _statusColor = _secondaryColor;
          _progressTimer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Depth Glow
          Positioned(
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primaryColor.withValues(alpha: 0.12),
                    _primaryColor.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Central Focal Point
          FadeTransition(
            opacity: _fadeInAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular Ring Loader
                  SizedBox(
                    width: 288, // ~w-72 equivalent
                    height: 288,
                    child: CustomPaint(
                      painter: ProgressRingPainter(
                        progress: _progress,
                        primaryColor: _primaryColor,
                        outlineColor: const Color(0xFF302840).withValues(alpha: 0.2),
                      ),
                    ),
                  ),

                  // Center Image Display
                  Container(
                    width: 224, // ~w-56 equivalent
                    height: 224,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                      child: Image.asset(
                        'assets/icons/element.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback placeholder if profile asset is empty
                          return Icon(
                            Icons.psychology, 
                            size: 80, 
                            color: _onBackground.withValues(alpha: 0.7)
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Branding Footer
          Positioned(
            bottom: 10, // bottom-16 equivalent
            child: FadeTransition(
              opacity: _fadeInAnimation, // HTML wraps both in entry animations
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Title Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "KEEPREMIND",
                        style: TextStyle(
                          fontFamily: 'Sora', // Fallback defaults safely if Google Fonts isn't bundled
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          color: _onBackground,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const PulsingCursor(color: Color(0xFFFF2D78)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sub-label
                  Text(
                    "NEURAL STORAGE",
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 5.4, // tracking-[0.6em]
                      color: _onBackground.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Async Status Controller Label
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: _statusColor,
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
}

// Custom Painter to cleanly handle the precise HTML stroke-dasharray properties
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color outlineColor;

  ProgressRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw Background Track (0.5 thickness outline)
    final bgPaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Draw Loading Progress Arc (1.0 thickness active stroke)
    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.square;

    double startAngle = -math.pi / 2; // Starts tracking top center (-90 degrees)
    double sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Custom Mini-widget to replicate Tailwind's animate-pulse cursor block next to branding text
class PulsingCursor extends StatefulWidget {
  final Color color;
  const PulsingCursor({super.key, required this.color});

  @override
  State<PulsingCursor> createState() => _PulsingCursorState();
}

class _PulsingCursorState extends State<PulsingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.2, end: 1.0).animate(_pulseController),
      child: Container(
        width: 6,
        height: 24,
        color: widget.color,
      ),
    );
  }
}