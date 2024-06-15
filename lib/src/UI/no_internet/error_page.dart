import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ErrorPage extends StatelessWidget {

  const ErrorPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgndColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation for No Internet
              Lottie.asset(
                'assets/animation/no_internet.json',
                width: 300,
                height: 300,
                repeat: true,
                reverse: true,
                animate: true,
              ),
              const SizedBox(height: 24.0),
              // Error Message
              Text(
                'Oops! No Internet Connection',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6.0),
              // Description
              Text(
                'Please check your network connection and try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}
