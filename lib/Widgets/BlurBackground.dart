
import 'package:flutter/material.dart';

class BlurryLoader extends StatelessWidget {
  const BlurryLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3), // semi-transparent overlay
      child: const Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}