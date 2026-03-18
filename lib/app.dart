import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class ReelRemindApp extends StatelessWidget {
  const ReelRemindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelRemind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 92, 3, 244)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}