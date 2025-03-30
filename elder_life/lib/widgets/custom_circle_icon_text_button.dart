import 'package:flutter/material.dart';

class CustomCircleIconTextButton extends StatelessWidget {
  final String? imagePath;
  final IconData? iconData;
  final String label;
  final VoidCallback onTap;

  const CustomCircleIconTextButton({
    super.key,
    this.imagePath,
    this.iconData,
    required this.label,
    required this.onTap,
  })  : assert(imagePath != null || iconData != null,
            'Either imagePath or iconData must be provided');

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (imagePath != null) {
      iconWidget = Image.asset(imagePath!, fit: BoxFit.contain);
    } else if (iconData != null) {
      iconWidget = Icon(iconData, size: 32, color: Colors.black);
    } else {
      iconWidget = const Icon(Icons.help_outline, size: 32, color: Colors.black);
    }

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          // Circular icon with drop shadow
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: iconWidget,
            ),
          ),
          const SizedBox(width: 12),
          // Text label
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
