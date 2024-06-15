import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  // Terms of Service Text (in Markdown format)
  final String termsOfServiceText = '''
## 1. **Introduction**
Welcome to CU Events! These Terms of Service ("Terms") govern your use of the CU Events mobile application ("App"). 

## 2. **User Conduct**
- You agree to use the App responsibly and not for any illegal or harmful activities.
- You will not post any content that is offensive, abusive, or violates the rights of others.

## 3. **Content and Intellectual Property**
- You retain ownership of any content you create and share through the App.
- We reserve the right to moderate and remove any content that violates these Terms.
- All intellectual property rights in the App and its content belong to us.

## 4. **Privacy**
Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.

## 5. **Disclaimers and Limitation of Liability**
- We provide the App "as is" and do not guarantee its accuracy, availability, or fitness for a particular purpose.
- We are not liable for any damages arising from your use of the App.

## 6. **Changes to the Terms**
We may update these Terms from time to time. Please check back regularly for any changes.
  '''; // Replace with your actual terms of service text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgndColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms of Service',
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 8, right: 8,bottom: 8),
        child: Markdown(
          data: termsOfServiceText,
          styleSheet: MarkdownStyleSheet(
            h1: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor, // Use your primary text color
            ),
            h2: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textColor, // Use your primary text color
            ),
            p: GoogleFonts.montserrat(
              fontSize: 16,
              height: 1.6,
              color: textColor,
            ),
            a: const TextStyle(
              // Style for links
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          onTapLink: (text, href, title) {
            _launchURL(href!); // Launch link in browser
          },
        ),
      ),
    );
  }

  // Function to launch URL in browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $uri';
    }
  }
}
