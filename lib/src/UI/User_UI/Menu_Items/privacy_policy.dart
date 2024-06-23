import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

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
            'Privacy policy',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          elevation: 0,
          backgroundColor: greyColor,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPolicySection(
                  '1. Information We Collect',
                  [
                    _buildPolicyPoint(
                        'Email Address:',
                        'We collect your email address if you choose to create an account for user login purposes. You have the option to skip this step and use the app anonymously.',
                        context),
                    _buildPolicyPoint(
                        'Usage Data:',
                        'We may collect certain information automatically when you use the app, such as your device type, operating system version, and usage statistics.',
                        context),
                  ],
                  context,
                ),
                _buildPolicySection(
                  '2. Use of Your Information',
                  [
                    _buildPolicyPoint(
                        '',
                        'We may use the information we collect in the following ways:',
                        context),
                    _buildPolicyPoint('-',
                        'To provide, operate, and maintain our app.', context),
                    _buildPolicyPoint(
                        '-',
                        'To improve, personalize, and customize the app experience.',
                        context),
                    _buildPolicyPoint(
                        '-',
                        'To understand and analyze how you use our app and develop new products, services, features, and functionality.',
                        context),
                    _buildPolicyPoint(
                        '-',
                        'To communicate with you, either directly or through one of our partners, including for customer service, to provide you with updates and other information relating to the app, and for marketing and promotional purposes.',
                        context),
                  ],
                  context,
                ),
                _buildPolicySection(
                  '3. Disclosure of Your Information',
                  [
                    _buildPolicyPoint(
                        '',
                        'We may share your information with third parties only in the ways that are described in this privacy policy:',
                        context),
                    _buildPolicyPoint('-', 'With your consent.', context),
                    _buildPolicyPoint('-', 'To comply with laws.', context),
                    _buildPolicyPoint('-', 'To protect our rights.', context),
                  ],
                  context,
                ),
                _buildPolicySection(
                  '4. Third-Party Advertisers',
                  [
                    _buildPolicyPoint(
                        '',
                        'CU EVENTS uses Google AdMob to serve advertisements within the app. AdMob may use cookies and similar technologies to collect certain information for advertising purposes. This information may include your device type, IP address, and location data. AdMob\'s use of this information is governed by Google\'s Privacy Policy. You can review Google\'s privacy policy at:',
                        context),
                  ],
                  context,
                ),
                _buildPolicySection(
                  '5. Security of Your Information',
                  [
                    _buildPolicyPoint(
                        '',
                        'We use administrative, technical, and physical security measures to help protect your personal information. However, please be aware that no method of transmission over the internet or electronic storage is completely secure and we cannot guarantee the absolute security of your data.',
                        context),
                  ],
                  context,
                ),
                _buildPolicySection(
                  '6. Children\'s Privacy',
                  [
                    _buildPolicyPoint(
                        '',
                        'CU EVENTS does not knowingly collect personal information from children under the age of 13. If we learn that we have collected personal information from a child under age 13 without verification of parental consent, we will delete that information as quickly as possible. If you believe that we might have any information from or about a child under 13, please contact us at support.cuevents@gmail.com.',
                        context),
                  ],
                  context,
                ),
                _buildPolicySection(
                  '7. Changes to This Privacy Policy',
                  [
                    _buildPolicyPoint(
                        '',
                        'We may update this Privacy Policy from time to time in order to reflect, for example, changes to our practices or for other operational, legal, or regulatory reasons.',
                        context),
                  ],
                  context,
                ),
                _buildPolicySection(
                  '8. Contact Us',
                  [
                    _buildPolicyPoint(
                        '',
                        'If you have any questions about this Privacy Policy, please contact us at support.cuevents@gmail.com.',
                        context),
                  ],
                  context,
                ),
                _buildPolicySubheader('Effective Date: 18-06-2024', context),
              ],
            ),
          ),
        ));
  }

  Widget _buildPolicySubheader(String subtitle, BuildContext context) {
    return Text(
      subtitle,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildPolicySection(
      String title, List<Widget> children, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPolicySubheader(title, context),
        const SizedBox(height: 10),
        ...children,
        const SizedBox(height: 16), // Add spacing between sections
      ],
    );
  }

  Widget _buildPolicyPoint(String bullet, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bullet.isNotEmpty) Text(bullet),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontWeight: FontWeight.w300)),
          ),
        ],
      ),
    );
  }
}
