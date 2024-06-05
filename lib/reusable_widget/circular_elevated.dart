import 'package:flutter/material.dart';

class CircularElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const CircularElevatedButton({
    Key? key,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  _CircularElevatedButtonState createState() => _CircularElevatedButtonState();
}

class _CircularElevatedButtonState extends State<CircularElevatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _isPressed ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: _isPressed
              ? const LinearGradient(
                  colors: [Color(0xFFDE3163), Color(0xFFDE3163)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFEC6C8E), Color(0xFFF7879A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.white.withOpacity(0.2),
              onTap: widget.onPressed,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
            ),
          ),
        ),
      ),
    );
  }
}
