import 'dart:io';

import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flip_card/flip_card.dart';
import 'package:share_plus/share_plus.dart';

class InviteFriendsPage extends StatefulWidget {
  const InviteFriendsPage({super.key});

  @override
  State<InviteFriendsPage> createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {
  final String appStoreLink = 'https://apps.apple.com/app/yourappname';
  final String playStoreLink =
      'https://play.google.com/store/apps/details?id=yourappname';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Friends',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        margin: const EdgeInsets.all(16), // Uniform margin for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Share the Joy of Our Events App!',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Invite your friends and family to join you in discovering and enjoying amazing events.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FlipCard(
                direction: FlipDirection.HORIZONTAL,
                front: _buildCardFace(
                  context,
                  'Scan & Download',
                  _buildQRView(),
                  Colors.deepPurple,
                  Colors.purpleAccent,
                  Platform.isAndroid ? playStoreLink : appStoreLink,
                  false,
                ),
                back: _buildCardFace(
                  context,
                  'Share the Link',
                  _buildLinkView(),
                  Colors.teal,
                  Colors.tealAccent,
                  Platform.isAndroid ? playStoreLink : appStoreLink,
                  true,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Tap the card to flip ',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 5),
            Lottie.asset(
              'assets/animation/invite.json',
              height: 190,
              repeat: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFace(BuildContext context, String title, Widget content,
      Color startColor, Color endColor, String appLink, bool isIcon) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        // height: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.only(
            top: 15,
            bottom: 15,
            left: 25,
            right: 25), // Increased padding for better spacing
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isIcon
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: appLink));
                          showCustomSnackBar(context, 'Copied to clipboard');
                        },
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  QrImageView _buildQRView() {
    return QrImageView(
      data: Platform.isAndroid ? playStoreLink : appStoreLink,
      version: QrVersions.auto,
      size: 250.0,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildLinkView() {
    final appLink = Platform.isAndroid ? playStoreLink : appStoreLink;

    return Column(
      children: [
        Text(
          appLink,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: whiteColor),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
          ),
          onPressed: () => Share.share(appLink),
          child: Text(
            'Share Link',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
