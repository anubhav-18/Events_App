// import 'package:cu_events/src/reusable_widget/custom_button.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../constants.dart';

// class LogoutDialog extends StatelessWidget {
//   final VoidCallback onLogout;

//   const LogoutDialog({Key? key, required this.onLogout}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     return AlertDialog(
//       titlePadding: EdgeInsets.zero,
//       contentPadding:EdgeInsets.zero,
//       backgroundColor: backgndColor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15.0),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Message Text
//           const SizedBox(height: 12.0),
//           Text(
//             'Log Out?',
//             style: Theme.of(context).textTheme.headlineMedium,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 12.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'Cancel',
//                   style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                         color: primaryBckgnd,
//                       ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: onLogout,
//                 child: Text(
//                   'Logout',
//                   style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                         color: primaryBckgnd,
//                       ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6.0),
//         ],
//       ),
//     );
//   }
// }

import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Make sure you have the lottie package installed

class LogoutDialog extends StatelessWidget {
  final VoidCallback onLogout; // Callback function for logout

  const LogoutDialog({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgndColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie Animation (Replace with your own Lottie animation)
          CircleAvatar(
            radius: 70,
            backgroundColor: greyColor,
            child: Lottie.asset(
              'assets/animation/crying2.json',
              height: 110,
              width: 110,
              repeat: true,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.montserrat(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24.0), // Add spacing

          // Cancel and OK Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Even spacing
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: primaryBckgnd,
                      ),
                ),
              ),
              TextButton(
                onPressed: onLogout,
                child: Text(
                  'Logout',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: primaryBckgnd,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
