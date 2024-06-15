import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  int _expandedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16.0), // Add padding for better visual spacing
        child: ListView(
          children: faqList
              .asMap() // Convert list to map with index
              .entries
              .map((entry) => _buildFAQItem(
                    entry
                        .key, // Pass the index to keep track of the expanded tile
                    entry.value['question'] ?? "Question Not Available",
                    entry.value['answer'] ?? "Answer Not Available",
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFAQItem(int index, String question, String answer) {
    bool isExpanded = index == _expandedIndex;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (bool expanded) {
            setState(() => _expandedIndex = expanded ? index : -1);
          },
          title: Text(
            question,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          collapsedBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          expandedAlignment: Alignment.topLeft,
          iconColor: primaryBckgnd,
          collapsedIconColor: Colors.black,
          // Change the trailing icon based on expansion state
          trailing: Icon(
            isExpanded ? Icons.remove : Icons.add,
            color: primaryBckgnd,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Text(
                answer,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  height: 1.5,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List faqList = [
  {
    "question": "What is CU Events?",
    "answer":
        "CU Events is a mobile application designed to keep you updated with all the events happening at Chandigarh University. It provides a centralized platform to discover, participate in, and enjoy various activities on campus."
  },
  {
    "question": "How can I download the CU Events app?",
    "answer":
        "You can download the CU Events app from the Apple App Store for iOS devices and the Google Play Store for Android devices. Just search for 'CU Events', and you'll find our app ready to install."
  },
  {
    "question": "Is CU Events free to use?",
    "answer": "Yes, CU Events is completely free to download and use. Our goal is to ensure everyone at Chandigarh University can easily access event information without any cost.",
  },
  {
    "question": "Do I need to create an account to use the app?",
    "answer": "While you can browse events without an account, creating an account allows you to personalize your experience, set reminders, and receive notifications for events you are interested in.",
  },
  {
    "question": "How can I find events that match my interests?",
    "answer": "Once you create an account, you can set your preferences in the app. Based on your interests, CU Events will curate a personalized feed of events that match what you like.",
  },
  {
    "question": "How often is the event information updated?",
    "answer": "We work closely with event organizers to ensure that all information is up-to-date. Event details are updated in real-time to provide you with the most accurate and current information.",
  },
  {
    "question": "Can I share events with my friends?",
    "answer": "Yes, you can share event details with your friends directly from the app through social media, email, or messaging platforms.",
  },
  {
    "question": "How can I contact the event organizers?",
    "answer": "Each event listing includes contact details of the organizers. You can reach out to them directly through the provided email or phone number for any specific queries.",
  },
  {
    "question": "What types of events are listed on CU Events?",
    "answer": "CU Events lists a wide range of activities, including academic seminars, cultural festivals, sports events, club meetings, workshops, and much more. There's something for everyone!",
  },
  {
    "question": "Can I submit an event to be listed on CU Events?",
    "answer": "es, if you are an event organizer at Chandigarh University, you can submit your event details through the app. Our team will review and approve it to be listed.",
  },
  {
    "question": "Who can I contact for technical support or feedback?",
    "answer": "For technical support or to provide feedback, you can reach us at [contact email/phone number]. We value your input and are here to help!",
  },
];
