import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgndColor,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          'About Us',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        elevation: 0,
        backgroundColor: greyColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Welcome to CU Events', context),
            _buildSectionContent(
              'Welcome to CU Events, Your ultimate gateway to all events happening at Chandigarh University! '
              'Our mission is to bring the vibrant campus life right to your fingertips, making it easier for students, '
              'faculty, and visitors to stay informed and engaged with the multitude of activities taking place within the university.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Who We Are', context),
            _buildSectionContent(
              'We are a passionate team of developers, students, and event enthusiasts who believe in the power of connectivity '
              'and engagement. With diverse backgrounds and a shared vision, we have come together to create an app that enriches '
              'the university experience by centralizing information about all events happening on campus.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Our Vision', context),
            _buildSectionContent(
              'At CU Events, our vision is to foster a more connected and engaged university community. We aim to make it effortless '
              'for everyone to discover, participate in, and enjoy the wide array of events that Chandigarh University has to offer. '
              'Whether it’s academic seminars, cultural festivals, sports meets, or club activities, CU Events ensures you never miss '
              'out on any opportunity to learn, network, and have fun.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('What We Offer', context),
            _buildBulletPoints([
              'Comprehensive Event Listings: Stay updated with a comprehensive and up-to-date calendar of all events happening on campus.',
              'Personalized Experience: Customize your event feed based on your interests and preferences.',
              'Reminders and Notifications: Receive timely reminders and notifications so you never miss an event.',
              'Easy Access: Effortlessly access event details, including date, time, venue, and organizer information.',
              'Community Engagement: Connect with event organizers and fellow participants to enhance your event experience.',
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Why Choose CU Events', context),
            _buildBulletPoints([
              'User-Friendly Interface: Our app is designed to be intuitive and easy to navigate, ensuring a seamless user experience.',
              'Up-to-Date Information: We work closely with event organizers to provide the most accurate and timely information.',
              'Engagement and Networking: CU Events is more than just an app; it’s a platform to engage, network, and make the most out of your university life.',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: textColor, // Use your primary text color
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        height: 1.6,
        color: textColor,
      ),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((point) => _buildBulletPoint(point)).toList(),
    );
  }

  Widget _buildBulletPoint(String point) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
            child: Text(
              point,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.6,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
