import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart'; 

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
        DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField<String>(
              value: value,
              items: items,
              dropdownColor: whiteColor,
              onChanged: onChanged,
              validator: validator,
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                enabledBorder: showBorder
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: greycolor2,
                          width: 2.0,
                        ),
                      )
                    : InputBorder.none,
                border: showBorder
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: greycolor2,
                          width: 2.0,
                        ),
                      )
                    : InputBorder.none,
                focusedBorder: showBorder
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: greycolor2,
                          width: 2.0,
                        ),
                      )
                    : InputBorder.none,
                errorBorder: showBorder
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      )
                    : InputBorder.none,
                focusedErrorBorder: showBorder
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      )
                    : InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
