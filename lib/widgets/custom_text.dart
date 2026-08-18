import 'package:flutter/material.dart';

// This custom widget is used to make Text widgets easier to reuse.
class CustomText
    extends StatelessWidget {
  final String text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontweight;
  final TextAlign textAlign;
  final double letterSpacing;
  final FontStyle fontStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  // This constructor sets the text and its optional styles.
  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 12,
    this.fontFamily = 'Poppins',
    this.fontweight =
        FontWeight.normal,
    this.textAlign =
        TextAlign.left,
    this.letterSpacing = 0,
    this.fontStyle =
        FontStyle.normal,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    // This returns a Text widget using the custom settings.
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,

      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontweight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
      ),
    );
  }
}