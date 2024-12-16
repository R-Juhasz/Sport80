import 'dart:async';
import 'package:flutter/material.dart';

class WelcomeMessage extends StatefulWidget {
  final String email;
  const WelcomeMessage({super.key, required this.email});

  @override
  _WelcomeMessageState createState() => _WelcomeMessageState();
}

class _WelcomeMessageState extends State<WelcomeMessage> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isVisible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10), // Adds rounded corners
          border: Border.all(color: Colors.white, width: 1.5), // Ensures the border is visible and styled
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add some padding to the container
        child: Text(
          'Welcome ${widget.email}!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

