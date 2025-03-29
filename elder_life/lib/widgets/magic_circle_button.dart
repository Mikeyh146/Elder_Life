import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MagicCircleButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final String svgIcon;      // We'll pass in an SVG string here
  final Color iconColor;     // Color to tint the SVG

  const MagicCircleButton({
    Key? key,
    required this.label,
    required this.onTap,
    required this.svgIcon,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  State<MagicCircleButton> createState() => _MagicCircleButtonState();
}

class _MagicCircleButtonState extends State<MagicCircleButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp([TapUpDetails? details]) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Needed so ripple can be seen
      child: InkWell(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        splashColor: Colors.white24, // Ripple color
        borderRadius: BorderRadius.circular(40),
        child: AnimatedScale(
          scale: _isPressed ? 1.1 : 1.0, // Subtle "glow" scale
          duration: const Duration(milliseconds: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular background with gradient + shadow
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: SvgPicture.string(
                  widget.svgIcon,
                  width: 32,
                  height: 32,
                  color: widget.iconColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
