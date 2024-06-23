import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart';
import 'package:google_fonts/google_fonts.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  bool isLoading = false,
  bool isDuration = false,
  Duration time = const Duration(
    days: 1,
  ),
}) {
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
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: CircularProgressIndicator(
              color: whiteColor,
              strokeWidth: 2,
            ),
          ),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(
      bottom: MediaQuery.of(context).size.height * 0.03,
    ),
    duration: isDuration ? time : const Duration(seconds: 2),
    elevation: 6.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
