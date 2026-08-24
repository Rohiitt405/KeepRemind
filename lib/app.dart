import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/saved_link_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'constants/app_theme.dart';
import 'screens/add_url_screen.dart';
import 'screens/share_loading_screen.dart';
import 'screens/splash_screen.dart';
import './providers/update_provider.dart';

class KeepRemindApp extends StatefulWidget {
  const KeepRemindApp({super.key});

  @override
  State<KeepRemindApp> createState() => _KeepRemindAppState();
}

class _KeepRemindAppState extends State<KeepRemindApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _shareSubscription;
  String? _pendingUrl;
  bool _shareIntentChecked = false;
  bool _shareFlowActive = false;
  bool _shareLoadingRouteVisible = false;

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
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((media) {
          if (media.isNotEmpty) {
            final url = _extractUrl(media);
            if (url != null && url.isNotEmpty) {
              setState(() {
                _pendingUrl = url;
                _shareFlowActive = true;
                _shareIntentChecked = true;
              });
              _tryNavigate(url);
            } else {
              setState(() {
                _shareIntentChecked = true;
              });
            }
            ReceiveSharingIntent.instance.reset();
          } else {
            setState(() {
              _shareIntentChecked = true;
            });
          }
        })
        .catchError((e) {
          debugPrint('Error getting initial media: $e');
        });

    _shareSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (media) {
        if (media.isNotEmpty) {
          final url = _extractUrl(media);
          if (url != null && url.isNotEmpty) {
            _showShareLoading(url);
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

  void _showShareLoading(String? url) {
    if (!mounted) return;

    setState(() {
      _pendingUrl = url;
      _shareFlowActive = true;
      _shareIntentChecked = true;
    });

    if (_shareLoadingRouteVisible) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = _navigatorKey.currentState;
      if (nav != null && mounted) {
        setState(() {
          _shareLoadingRouteVisible = true;
        });
        nav.push(
          MaterialPageRoute(
            builder: (_) => ShareLoadingScreen(initialUrl: url),
            fullscreenDialog: true,
          ),
        );
      }
    });
  }

  void _tryNavigate(String url) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;

        final nav = _navigatorKey.currentState;
        if (nav != null) {
          setState(() {
            _shareLoadingRouteVisible = false;
          });
          nav.pushReplacement(
            MaterialPageRoute(builder: (_) => AddUrlScreen(initialUrl: url)),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowShareLoading = _shareFlowActive || !_shareIntentChecked;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SavedLinkProvider()..listenToSavedLinks(),
        ),
        ChangeNotifierProvider(create: (_) => UpdateProvider()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'KeepRemind',
        debugShowCheckedModeBanner: false,
        theme: AppThemeConstants.buildTheme(),
        home: shouldShowShareLoading
            ? ShareLoadingScreen(initialUrl: _pendingUrl)
            : const SplashScreen(),
      ),
    );
  }
}
