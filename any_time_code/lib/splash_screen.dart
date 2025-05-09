
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'launch_screen.dart';
import 'main.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final lastOpened = prefs.getInt("lastOpened") ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Always show LaunchScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LaunchScreen()),
      );

      await prefs.setInt("lastOpened", now);
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1e1e1e),
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.code, size: 100, color: Colors.deepPurpleAccent),
              SizedBox(height: 20),
              Text(
                "TheCodeEditor",
                style: GoogleFonts.firaCode(
                    fontSize: 24, color: Colors.deepPurpleAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}