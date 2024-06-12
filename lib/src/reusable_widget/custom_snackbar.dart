import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart';
import 'package:google_fonts/google_fonts.dart';

void showCustomSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  final Color backgroundColor = isError ? Colors.red : primaryBckgnd;

  final snackBar = SnackBar(
    content: Row(
      children: [
        // Optional icon based on error or success
        isError
            ? const Icon(Icons.error_outline, color: Colors.white)
            : const Icon(Icons.check_circle_outline, color: Colors.white),
        const SizedBox(width: 10),
        Flexible(
          // Wrap text in Flexible to allow wrapping
          child: Column(
            // Use a Column for better text layout
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.02, left: 16, right: 16),
    duration: const Duration(seconds: 3),
    elevation: 6.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25.0),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
