import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'providers/reel_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'screens/add_url_screen.dart';

class ReelRemindApp extends StatefulWidget {
  const ReelRemindApp({super.key});

  @override
  State<ReelRemindApp> createState() => _ReelRemindAppState();
}

class _ReelRemindAppState extends State<ReelRemindApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _shareSubscription;
  String? _pendingUrl;
  bool _onboardingDone = false;
  bool _checkingOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _handleShareIntents();
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    super.dispose();
  }

  // Check if onboarding was already completed
  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboardingDone = prefs.getBool('onboarding_done') ?? false;
      _checkingOnboarding = false;
    });
  }

  void _handleShareIntents() {
    ReceiveSharingIntent.instance.getInitialMedia().then((media) {
      if (media.isNotEmpty) {
        final url = _extractUrl(media);
        if (url != null && url.isNotEmpty) {
          _pendingUrl = url;
          _tryNavigate(url);
        }
        ReceiveSharingIntent.instance.reset();
      }
    }).catchError((e) {
      debugPrint('Error getting initial media: $e');
    });

    _shareSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen(
      (media) {
        if (media.isNotEmpty) {
          final url = _extractUrl(media);
          if (url != null && url.isNotEmpty) {
            _tryNavigate(url);
          }
        }
      },
      onError: (error) {
        debugPrint('Share stream error: $error');
      },
    );
  }

  String? _extractUrl(List<SharedMediaFile> media) {
    final item = media.first;
    final text = item.path;
    final urlRegex = RegExp(r'https?://\S+');
    final match = urlRegex.firstMatch(text);
    return match?.group(0) ?? text;
  }

  void _tryNavigate(String url) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = _navigatorKey.currentState;
      if (nav != null) {
        _pendingUrl = null;
        nav.push(
          MaterialPageRoute(
            builder: (_) => AddUrlScreen(initialUrl: url),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingUrl != null) {
      final url = _pendingUrl!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pendingUrl != null) _tryNavigate(url);
      });
    }

    return ChangeNotifierProvider(
      create: (_) => ReelProvider()..listenToReels(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'ReelRemind',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Show splash while checking, then onboarding or home
        home: _checkingOnboarding
            ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : _onboardingDone
                ? const HomeScreen()
                : const OnboardingScreen(),
        // home: OnboardingScreen(),
      ),
    );
  }
}