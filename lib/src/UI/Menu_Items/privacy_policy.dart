import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionContent(
                'Your privacy is important to us. This privacy policy document outlines the types of information CU EVENTS ("we", "our", or "us") collects and records and how we use it.',
                context),
            const SizedBox(height: 20),
            _buildSectionTitle('1. Information We Collect', context),
            _buildSectionContent(
                'We do not collect any personal information from users. Our app is designed solely to provide information regarding events taking place in our college. We do not require users to provide any personal data to access or use the app.',
                context),
            const SizedBox(height: 20),
            _buildSectionTitle('2. How We Use Information', context),
            _buildSectionContent(
                'Since we do not collect any personal information, we do not use, share, or disclose any user data. The app functions as an informational resource, listing upcoming events categorized by departments such as Engineering, Business, Medical, Law, and Others.',
                context),
            const SizedBox(height: 20),
            _buildSectionTitle('3. Third-Party Services', context),
            _buildSectionContent(
              'Our app does not use any third-party services that collect, monitor, or analyze user data.',
              context,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('4. Security', context),
            _buildSectionContent(
                'We are committed to ensuring that your information is secure. Although we do not collect personal data, we take the security of the event information we provide very seriously and implement appropriate measures to protect it.',
                context),
            const SizedBox(height: 20),
            _buildSectionTitle('5. Links to Other Sites', context),
            _buildSectionContent(
                'Our app may contain links to external sites that are not operated by us. If you click on a third-party link, you will be directed to that third party\'s site. We strongly advise you to review the privacy policy of every site you visit. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.',
                context),
            const SizedBox(height: 20),
            _buildSectionTitle('6. Children’s Privacy', context),
            _buildSectionContent(
                'Our app does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13. If we discover that a child under 13 has provided us with personal information, we will delete such information immediately. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to take necessary actions.',
                context),
            const SizedBox(height: 20),
            _buildSectionTitle('7. Changes to This Privacy Policy', context),
            _buildSectionContent(
                'We may update our Privacy Policy from time to time. Thus, we advise you to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.',
                context),
            const SizedBox(height: 20),
            _buildSectionTitle('8. Contact Us', context),
            _buildSectionContent(
                'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@cuevents.com.',
                context),
            const SizedBox(height: 20),
            _buildSectionContent(
              'By using our app, you hereby consent to our Privacy Policy and agree to its terms.',
              context,
            ),
            const SizedBox(height: 20),
             _buildSectionSubtitle('Last updated: 20-06-2024'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor, // Use your primary text color
      ),
    );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSectionContent(String content, BuildContext context) {
    return Text(
      content,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        height: 1.6,
        color: textColor,
      ),
    );
  }
}
