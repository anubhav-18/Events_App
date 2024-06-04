import 'package:cu_events/constants.dart';
import 'package:flutter/material.dart';

SizedBox elevatedButton(
  BuildContext context,
  Function()? onPressed,
  String title,
  double? width,
) {
  return SizedBox(
    width: width ?? MediaQuery.of(context).size.width * 0.4,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 5),
        backgroundColor: primaryBckgnd,
      ),
      child: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 18)),
    ),
  );
}
