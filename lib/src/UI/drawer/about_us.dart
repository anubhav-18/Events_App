import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16), // Add margin around the content
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgndColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to CU Events!',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: primaryBckgnd),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your one-stop shop for all the latest and greatest events happening at Chandigarh University.',
              ),
              const SizedBox(height: 20),
              const Text(
                'Our app features:',
              ),
              const SizedBox(height: 10),
              _buildFeatureItem('Discover', 'Find events that match your interests.',context),
              _buildFeatureItem('Register', 'Sign up for events with ease.',context),
              _buildFeatureItem('Stay Informed', 'Get notifications about upcoming events.',context),
              _buildFeatureItem('Share', 'Spread the word and invite friends.',context),
              const SizedBox(height: 20),
              const Text(
                'We are committed to enhancing your campus experience by providing you with easy access to a vibrant and diverse range of events. Download our app today and never miss out on the fun!',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
