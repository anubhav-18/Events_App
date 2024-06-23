import 'dart:async';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/controller/auth_gate.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
    _controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    )..forward();

    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad);

    Timer(const Duration(seconds: 2, milliseconds: 500), () {
      // Adjust timing as needed
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // Use MaterialPageRoute to pass context to AuthGate
          builder: (context) => const AuthGate(),
        ),
      );
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
      backgroundColor: primaryBckgnd,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Image.asset(
                'assets/icons/logo/cuevents-removebg.png',
                width: 240,
                height: 240,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
