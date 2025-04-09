import 'package:flutter/material.dart';

class NetflixLogo extends StatelessWidget {
  final double height;
  
  const NetflixLogo({
    super.key,
    this.height = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Text(
        'NETFLIX',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: -1,
        ),
      ),
    );
  }
} 