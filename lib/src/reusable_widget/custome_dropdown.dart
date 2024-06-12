import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart'; // Import your color palette
import 'package:google_fonts/google_fonts.dart';

class CustomDropdown extends StatelessWidget {
  final String labelText;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool showBorder;

  const CustomDropdown({
    Key? key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
                color: primaryBckgnd, width: 2.0), // Use your color palette
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField<String>(
                value: value,
                items: items,
                onChanged: onChanged,
                validator: validator,
                decoration: InputDecoration(
                  hintText: 'Select an option',
                  hintStyle: GoogleFonts.montserrat(),
                  border: showBorder
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: primaryBckgnd,
                            width: 1.0,
                          ), // Use your color palette
                        )
                      : InputBorder.none,
                  focusedBorder: showBorder
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: primaryBckgnd,
                            width: 1.0,
                          ),
                        )
                      : InputBorder.none,
                  errorBorder: showBorder
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        )
                      : InputBorder.none,
                  focusedErrorBorder: showBorder
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        )
                      : InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
