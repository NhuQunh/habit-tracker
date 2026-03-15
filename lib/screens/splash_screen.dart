import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(onToggleTheme: widget.onToggleTheme),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen.shade100,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.track_changes_rounded,
              size: 84,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Habit Tracker',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.green.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
