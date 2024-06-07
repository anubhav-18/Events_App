import 'package:flutter/material.dart';
import 'package:cu_events/constants.dart';

void showCustomSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor: primaryBckgnd, // Your app's primary color
    behavior: SnackBarBehavior.floating, // Make it float above other elements
    shape: RoundedRectangleBorder( // Add rounded corners
      borderRadius: BorderRadius.circular(25.0),
    ),
    margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05, left: 16, right: 16),
    duration: const Duration(seconds: 3), // Adjust duration as needed
    action: SnackBarAction(
      label: 'Close',
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
