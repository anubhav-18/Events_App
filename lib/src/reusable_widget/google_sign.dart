import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleSignInButton extends StatelessWidget {
  final Function() onPressed;

  const GoogleSignInButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: textColor,  
        padding: EdgeInsets.zero,
        shape: const CircleBorder(), // Circular shape
        elevation: 4,
      ),
      child: Container(
        padding: const EdgeInsets.all(12), // Adjust padding as needed
        child: SvgPicture.asset(
          'assets/icons/google.svg',  // Path to your Google "G" logo SVG
          height: 24.0, // Adjust icon size as needed
        ),
      ),
    );
  }
}
