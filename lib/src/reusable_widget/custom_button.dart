import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatefulWidget {
  final Function()? onPressed;
  final String title;
  final double? width;
  final double? height;
  final bool widget; // Changed this to non-nullable
  final Widget? child;

  const CustomElevatedButton(
      {Key? key,
      required this.onPressed,
      required this.title,
      this.width,
      this.height,
      this.widget = false, // Default to false if not provided
      this.child})
      : super(key: key);

  @override
  _CustomElevatedButtonState createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: primaryBckgnd,
      end: primaryBckgnd.withOpacity(0.8), // Slightly darker shade on press
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? MediaQuery.of(context).size.width * 0.4,
      height: widget.height ?? MediaQuery.of(context).size.height * 0.07,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onPressed != null) {
                  _controller.forward().then((value) =>
                      _controller.reverse()); // Trigger animation on press
                  widget.onPressed!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorAnimation.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                elevation: 5,
              ),
              child: widget.widget
                  ? widget.child ??
                      const SizedBox.shrink() // Render child if widget is true
                  : Text(
                      widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: whiteColor),
                    ),
            ),
          );
        },
      ),
    );
  }
}

SizedBox elevatedButton(
  BuildContext context,
  Function()? onPressed,
  String title,
  double? width,
  double? height,
) {
  return SizedBox(
    width: width ?? MediaQuery.of(context).size.width * 0.4,
    height: height ?? MediaQuery.of(context).size.height * 0.06,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 5),
          backgroundColor: primaryBckgnd,
          elevation: 5),
      child: Text(
        title,
        style:
            Theme.of(context).textTheme.bodyLarge!.copyWith(color: whiteColor),
      ),
    ),
  );
}
