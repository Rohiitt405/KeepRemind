import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'providers/reel_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_url_screen.dart';

class ReelRemindApp extends StatelessWidget {
  const ReelRemindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReelProvider()..listenToReels(),
      child: MaterialApp(
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

class ShareHandleScreen extends StatefulWidget {
  const ShareHandleScreen({super.key});

  @override
  State<ShareHandleScreen> createState() => _ShareHandleScreenState();
}

class _ShareHandleScreenState extends State<ShareHandleScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listenForSharedUrls();
  }
  
  void _listenForSharedUrls() {
    ReceiveSharingIntent.instance.getInitialMedia().then((media) {
      if(media.isNotEmpty) {
        final url = media.first.path;

        if(url.isNotEmpty) {
          _openAddScreenWithUrl(url);
        }
        ReceiveSharingIntent.instance.reset();
      }
    });

    ReceiveSharingIntent.instance.getMediaStream().listen((media) {
      if(media.isNotEmpty) {
        final url = media.first.path;
        if(url.isNotEmpty) {
          _openAddScreenWithUrl(url);
        }
      }
    });
  }
  
  void _openAddScreenWithUrl(String url) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (_) => AddUrlScreen(initialUrl: url)
          )
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}