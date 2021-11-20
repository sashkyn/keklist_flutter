import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkWidget extends StatelessWidget {
  final String item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MarkWidget({
    Key? key,
    required this.item,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Text(
          item,
          style: GoogleFonts.notoColorEmojiCompat(
            fontSize: 50,
          ),
        ),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
