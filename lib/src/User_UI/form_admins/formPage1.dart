// import 'package:flutter/material.dart';
// import 'package:horizontal_stepper_flutter/horizontal_stepper_flutter.dart';


// class OpportunityDetailsPage extends StatefulWidget {
//   @override
//   _OpportunityDetailsPageState createState() => _OpportunityDetailsPageState();
// }

// class _OpportunityDetailsPageState extends State<OpportunityDetailsPage> {
//   int currentStep = 0;

//   List<Step> steps = [
//     Step(
//       title: Text('Basic Details'),
//       content: BasicDetailsForm(),
//       state: StepState.indexed,
//       isActive: true,
//     ),
//     Step(
//       title: Text('Registration Details'),
//       content: Container(), // Add your registration details form here
//       state: StepState.indexed,
//       isActive: true,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         HorizontalStepper(
//           steps: steps,
//           currentStep: currentStep,
//           onStepTapped: (step) => setState(() => currentStep = step),
//           onStepContinue: currentStep < steps.length - 1
//               ? () => setState(() => currentStep += 1)
//               : null,
//           onStepCancel: currentStep > 0 ? () => setState(() => currentStep -= 1) : null,
//         ),
//         Expanded(
//           child: steps[currentStep].content,
//         ),
//       ],
//     );
//   }
// }

// class BasicDetailsForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Image.network(
//                 'https://example.com/logo.png', // Replace with your image URL
//                 height: 100,
//               ),
//             ),
//             SizedBox(height: 16),
//             Text('Opportunity Type'),
//             SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               items: ['General & Case Competitions']
//                   .map((label) => DropdownMenuItem(
//                         child: Text(label),
//                         value: label,
//                       ))
//                   .toList(),
//               onChanged: (value) {},
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             Text('Opportunity Sub Type'),
//             SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               items: ['Innovation Challenges']
//                   .map((label) => DropdownMenuItem(
//                         child: Text(label),
//                         value: label,
//                       ))
//                   .toList(),
//               onChanged: (value) {},
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             Text('Visibility'),
//             SizedBox(height: 8),
//             RadioListTile(
//               title: Text('Open publicly on Unstop'),
//               subtitle: Text('Will be visible to all Unstop users.'),
//               value: 'public',
//               groupValue: 'public', // Implement state management for selection
//               onChanged: (value) {},
//             ),
//             RadioListTile(
//               title: Text('Invite Only'),
//               value: 'invite',
//               groupValue: 'public', // Implement state management for selection
//               onChanged: (value) {},
//             ),
//             SizedBox(height: 16),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {},
//                 child: Text('Next'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
