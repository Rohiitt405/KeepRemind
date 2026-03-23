import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/reel_provider.dart';
import 'screens/home_screen.dart';

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