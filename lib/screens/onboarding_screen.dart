import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../widgets/shared/neo_brutalist_button.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Neo-Brutalist Color Palette Mapping
  static const Color primaryColor = AppThemeConstants.primaryColor;
  static const Color backgroundColor = AppThemeConstants.backgroundColor;
  static const Color surfaceContainerLow =
      AppThemeConstants.surfaceContainerLow;
  static const Color tertiaryFixed = AppThemeConstants.tertiaryFixed;
  static const Color onTertiaryFixed = AppThemeConstants.onTertiaryFixed;
  static const Color secondaryFixed = AppThemeConstants.secondaryFixed;
  static const Color quarterFixed = AppThemeConstants.quarterFixed;
  static const Color onSurfaceVariant = AppThemeConstants.onSurfaceVariant;

  late Timer _typewriterTimer;
  final String _headline1 = "STOP REWATCHING.";
  final String _headline2 = "START REMEMBERING.";
  String _displayHeadline1 = "";
  String _displayHeadline2 = "";
  bool _secondLineStarted = false;

  late Timer _ledTimer;
  bool _redLedOn = true;
  bool _yellowLedOn = false;

  bool _isInitializing = false;
  double _processorProgress = 0.8;
  String _processorStatus = "ANALYZING_BUFFER...";
  String _processorPercentage = "84%";

  late Timer _loaderTimer;
  bool _showCursor = true;

  // Custom Neo-Brutalist Box Shadow Vectors
  List<BoxShadow> get neoShadow => AppThemeConstants.neoShadow;

  List<BoxShadow> get neoShadowSm => AppThemeConstants.neoShadowSm;

  Future<void> _finish() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    _startLoaderAnimation();

    for (int i = 85; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 35));

      if (!mounted) return;

      setState(() {
        _processorProgress = i / 100;
        _processorPercentage = "$i%";
      });
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      _processorStatus = "SYSTEM_READY";
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (!mounted) return;

    _loaderTimer.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void initState() {
    super.initState();

    _startTypewriter();
    _startLedAnimation();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark, // Swapped to dark icons for light background
        systemNavigationBarColor: backgroundColor,
      ),
    );
  }

  @override
  void dispose() {
    _typewriterTimer.cancel();
    _ledTimer.cancel();
    _loaderTimer.cancel();
    super.dispose();
  }

  void _startLoaderAnimation() {
    _loaderTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted || !_isInitializing) return;

      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  void _startTypewriter() {
    int index = 0;

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 70), (
      timer,
    ) {
      if (!mounted) return;

      setState(() {
        if (!_secondLineStarted) {
          if (index < _headline1.length) {
            _displayHeadline1 += _headline1[index];
            index++;
          } else {
            _secondLineStarted = true;
            index = 0;
          }
        } else {
          if (index < _headline2.length) {
            _displayHeadline2 += _headline2[index];
            index++;
          } else {
            timer.cancel();
          }
        }
      });
    });
  }

  void _startLedAnimation() {
    _ledTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _redLedOn = !_redLedOn;
        _yellowLedOn = !_yellowLedOn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // TopAppBar Structure
                SliverAppBar(
                  expandedHeight: 70,
                  backgroundColor: backgroundColor,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  automaticallyImplyLeading: false,
                  shape: const Border(
                    bottom: BorderSide(color: primaryColor, width: 6),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'KEEP REMIND',
                      style: displayFont.copyWith(
                        fontSize: 28,
                        color: primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '[ SYSTEM_ALERT ]',
                                        style: monoFont.copyWith(
                                          fontSize: 14,
                                          color: quarterFixed,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'ID: 08-X92',
                                        style: monoFont.copyWith(
                                          fontSize: 12,
                                          color: onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  RichText(
                                    text: TextSpan(
                                      style: displayFont.copyWith(
                                        color: primaryColor,
                                        fontSize: 40,
                                        height: 1.1,
                                      ),
                                      children: [
                                        TextSpan(text: "$_displayHeadline1\n"),
                                        WidgetSpan(
                                          child: Container(
                                            color: tertiaryFixed,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Text(
                                              _displayHeadline2,
                                              style: displayFont.copyWith(
                                                color: onTertiaryFixed,
                                                fontSize: 44,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              Container(
                                decoration: BoxDecoration(
                                  color: AppThemeConstants.surfaceColor,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 6,
                                  ),
                                  boxShadow: neoShadow,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      color: primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'VISUAL_PROCESSOR_V1.0',
                                            style: monoFont.copyWith(
                                              fontSize: 14,
                                              color: AppThemeConstants
                                                  .surfaceColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: _redLedOn
                                                      ? const Color.fromARGB(
                                                          255,
                                                          255,
                                                          0,
                                                          0,
                                                        )
                                                      : const Color.fromARGB(
                                                          255,
                                                          255,
                                                          0,
                                                          0,
                                                        ).withValues(
                                                          alpha: 0.25,
                                                        ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: primaryColor,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: _yellowLedOn
                                                      ? secondaryFixed
                                                      : secondaryFixed
                                                            .withValues(
                                                              alpha: 0.25,
                                                            ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: primaryColor,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      color: surfaceContainerLow,
                                      height: 300,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ColorFiltered(
                                              colorFilter:
                                                  const ColorFilter.matrix([
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
                                              child: Image.asset(
                                                'assets/icons/sketch.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 16,
                                            left: 16,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: secondaryFixed,
                                                border: Border.all(
                                                  color: primaryColor,
                                                  width: 2,
                                                ),
                                                boxShadow: neoShadowSm,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _processorStatus,
                                                    style: monoFont.copyWith(
                                                      color: primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    _processorPercentage,
                                                    style: monoFont.copyWith(
                                                      color: primaryColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 8,
                                      color: primaryColor,
                                      width: double.infinity,
                                      alignment: Alignment.centerLeft,
                                      child: AnimatedFractionallySizedBox(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        curve: Curves.easeOut,
                                        widthFactor: _processorProgress,
                                        child: Container(color: secondaryFixed),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppThemeConstants.surfaceColor,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 4,
                                  ),
                                  boxShadow: neoShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.memory,
                                          color: primaryColor,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'CORE_FUNCTIONS',
                                          style: displayFont.copyWith(
                                            fontSize: 26,
                                            color: primaryColor,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: secondaryFixed,
                                            width: 6,
                                          ),
                                        ),
                                      ),
                                      padding: const EdgeInsets.only(left: 14),
                                      child: RichText(
                                        text: TextSpan(
                                          style: monoFont.copyWith(
                                            color: primaryColor,
                                            fontSize: 16,
                                            height: 1.3,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text:
                                                  'The ultimate memory tool for your saved SavedLinks & Shorts. ',
                                            ),
                                            WidgetSpan(
                                              child: Container(
                                                color: tertiaryFixed,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                    ),
                                                child: Text(
                                                  'AI-powered takeaways',
                                                  style: monoFont.copyWith(
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ', no rewatching required.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),

                              NeoBrutalistButton(
                                onPressed: _finish,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _isInitializing
                                              ? "INITIALIZING..."
                                              : "INITIALIZE_SYSTEM",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: displayFont.copyWith(
                                            color: primaryColor,
                                            fontSize: 32,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      _isInitializing
                                          ? SizedBox(
                                              width: 28,
                                              height: 28,
                                              child: Text(
                                                _showCursor ? "█" : "",
                                                style: monoFont.copyWith(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.arrow_forward,
                                              color: primaryColor,
                                              size: 36,
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                                children: [
                                  _buildGridCard(
                                    title: 'RECAP',
                                    description:
                                        'AI-distilled summaries of your saved savedLinks.',
                                    indicatorColor: tertiaryFixed,
                                    progress: 1.0,
                                    monoFont: monoFont,
                                  ),
                                  _buildGridCard(
                                    title: 'SMART SEARCH',
                                    description:
                                        'Natural language memory retrieval.',
                                    indicatorColor: secondaryFixed,
                                    progress: 0.66,
                                    icon: const Icon(
                                      Icons.search,
                                      size: 16,
                                      color: primaryColor,
                                    ),
                                    monoFont: monoFont,
                                  ),
                                  _buildGridCard(
                                    title: 'INSTANT SYNC',
                                    description:
                                        'Auto-ingest from Instagram & TikTok.',
                                    indicatorColor: quarterFixed,
                                    progress: 0.75,
                                    monoFont: monoFont,
                                  ),
                                  _buildGridCard(
                                    title: 'AI INSIGHTS',
                                    description:
                                        'Actionable data from visual data.',
                                    indicatorColor: const Color(0xFF009923),
                                    progress: 0.5,
                                    monoFont: monoFont,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Component Building Handler for Neo-Brutalist Features Cells
  Widget _buildGridCard({
    required String title,
    required String description,
    required Color indicatorColor,
    required double progress,
    required TextStyle monoFont,
    Widget? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeConstants.surfaceColor,
        border: Border.all(color: primaryColor, width: 4),
        boxShadow: neoShadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  border: Border.all(color: primaryColor, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: monoFont.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: monoFont.copyWith(color: onSurfaceVariant, fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            color: AppThemeConstants.surfaceContainerLow,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(color: indicatorColor),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Stateful Button Injecting Mechanical Layout Offset Shift on Actions
