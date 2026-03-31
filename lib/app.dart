import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'providers/reel_provider.dart';
import 'screens/home_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _handleShareIntents();
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    super.dispose();
  }

  void _handleShareIntents() {
    // Case 1: App launched from a share intent (cold start)
    ReceiveSharingIntent.instance.getInitialMedia().then((media) {
      if (media.isNotEmpty) {
        final url = _extractUrl(media);
        if (url != null && url.isNotEmpty) {
          _pendingUrl = url;
          // Try to navigate; if navigator isn't ready yet, it'll be
          // picked up by _consumePendingUrl called from build.
          _tryNavigate(url);
        }
        ReceiveSharingIntent.instance.reset();
      }
    }).catchError((e) {
      debugPrint('Error getting initial media: $e');
    });

    // Case 2: App already running, receives a share intent
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

  /// Extracts the shared URL from the media list.
  /// YouTube/Instagram share text/plain, so the URL could be in `path`
  /// (which holds the shared text for text-type shares).
  String? _extractUrl(List<SharedMediaFile> media) {
    final item = media.first;
    final text = item.path;
    // The shared content might contain extra text around the URL.
    // Try to extract a URL from it.
    final urlRegex = RegExp(r'https?://\S+');
    final match = urlRegex.firstMatch(text);
    return match?.group(0) ?? text;
  }

  void _tryNavigate(String url) {
    // Schedule navigation for after the current frame finishes building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = _navigatorKey.currentState;
      if (nav != null) {
        _pendingUrl = null; // consumed
        nav.push(
          MaterialPageRoute(
            builder: (_) => AddUrlScreen(initialUrl: url),
          ),
        );
      }
      // If nav is null, _pendingUrl stays set and will be consumed
      // when the navigator is ready (via _consumePendingUrl in build).
    });
  }

  @override
  Widget build(BuildContext context) {
    // After the MaterialApp builds, consume any pending URL that
    // couldn't be navigated to earlier.
    if (_pendingUrl != null) {
      final url = _pendingUrl!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pendingUrl != null) {
          _tryNavigate(url);
        }
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
        home: const HomeScreen(),
      ),
    );
  }
}