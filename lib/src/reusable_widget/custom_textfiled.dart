import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength; // Add max length property
  final int? maxLines;
  final bool isEnabled;
  final void Function(String)? onChanged; // Add onChanged property
  final bool boolValidator;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.hintText,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.maxLength,
    this.onChanged,
    this.maxLines,
    this.isEnabled = true,
    this.boolValidator = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
   bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Text (above)
        Text(
          widget.labelText,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText && _obscureText,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          enabled: widget.isEnabled,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          keyboardType: widget.keyboardType,
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.montserrat(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: primaryBckgnd, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: primaryBckgnd, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            errorStyle: GoogleFonts.montserrat(
              fontSize: 18, // Adjust the validator text size here
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: _obscureText ? Colors.grey : primaryBckgnd, // Change color based on state
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          validator: widget.boolValidator
              ? widget.validator
              : (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ${widget.labelText}';
                  }
                  return null;
                },
        ),
      ],
    );
  }
}
