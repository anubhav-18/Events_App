import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final bool prefixIcon;
  final bool isDateField;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool wantValidator;

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
    this.prefixIcon = false,
    this.isDateField = false,
    this.readOnly = false,
    this.wantValidator = true,
    this.onTap,
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
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText && _obscureText,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          enabled: widget.isEnabled,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          keyboardType: widget.isDateField
              ? widget.prefixIcon
                  ? TextInputType.phone
                  : TextInputType.none
              : widget.prefixIcon
                  ? TextInputType.phone
                  : widget.keyboardType,
          readOnly: widget.readOnly,
          onTap: widget.readOnly
              ? widget.isDateField
                  ? widget.onTap
                  : () {
                      showCustomSnackBar(context, 'Email cannot be change.');
                    }
              : widget.isDateField
                  ? widget.onTap
                  : null,
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '+91',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const VerticalDivider(
                        color: Colors.black,
                        thickness: 1,
                        width: 20,
                      ),
                    ],
                  )
                : null,
            labelText: widget.labelText,
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium,
            labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? null
                      : const Color(0xffd9dddc),
                ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: greycolor2, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: greycolor2, width: 2.0),
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
                    icon: _obscureText
                        ? SvgPicture.asset(
                            'assets/icons/eye.svg',
                            colorFilter: const ColorFilter.mode(
                                Colors.grey, BlendMode.srcIn),
                          )
                        : SvgPicture.asset(
                            'assets/icons/eye-slash.svg',
                            colorFilter: const ColorFilter.mode(
                                primaryBckgnd, BlendMode.srcIn),
                          ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          validator: widget.wantValidator
              ? widget.boolValidator
                  ? widget.validator
                  : (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your ${widget.labelText}';
                      }
                      return null;
                    }
              : null,
        ),
      ],
    );
  }
}
