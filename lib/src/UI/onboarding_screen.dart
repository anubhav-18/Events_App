import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/controller/tags.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/services/firestore_service.dart'; // Import your Firestore service
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final String userId;

  const OnboardingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<String> selectedTags = [];
  final FirestoreService _firestoreService = FirestoreService();
  int selectedTagCount = 0;
  bool isValidTagCount = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Let's Personalize Your Feed!",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        elevation: 0,
        backgroundColor: greyColor,
      ),
      // AppBar(
      //   title: const Text("Let's Personalize Your Feed!"),
      // ),
      body: SingleChildScrollView(
        // Allow scrolling if there are many tags
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Select 3-10 topics you love:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: allTags.map((tag) {
                  return ChoiceChip(
                    label: Text(tag),
                    selected: selectedTags.contains(tag),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          if (selectedTagCount < 10) {
                            selectedTags.add(tag);
                            selectedTagCount++;
                          } else {
                            showCustomSnackBar(context,
                                "You can select a maximum of 10 tags.");
                          }
                        } else {
                          selectedTags.remove(tag);
                          selectedTagCount--;
                        }
                        isValidTagCount =
                            (selectedTagCount >= 3 && selectedTagCount <= 10);
                      });
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: greyColor,
                    labelStyle: TextStyle(
                      color: selectedTags.contains(tag)
                          ? Colors.white
                          : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: isValidTagCount
              ? () async {
                  // Update user model in Firestore
                  await _firestoreService.updateUserInterests(
                      widget.userId, selectedTags);

                  // Navigate to homepage
                  Navigator.pushReplacementNamed(context, '/btmnav');
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: Text(
            "Let's Go!",
            style: TextStyle(
              color: isValidTagCount ? whiteColor : null,
            ),
          ), // Cool button text
        ),
      ),
    );
  }
}
