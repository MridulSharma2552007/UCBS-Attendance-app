import 'package:flutter/material.dart';

class AppColors {
  // Base Dark Backgrounds
  static const Color bgDark = Color.fromARGB(255, 0, 0, 0); // true dark
  static const Color bgLightDark = Color(
    0xFF181818,
  ); // slightly raised surfaces
  static const Color cardDark = Color(0xFF1E1E1E); // cards & panels

  // Text Colors
  static const Color textPrimary = Color(0xFFEDEDED); // main text
  static const Color textSecondary = Color(0xFF9E9E9E); // muted text
  static const Color textFaded = Color(0xFF6B6B6B); // placeholder text

  // Accent Colors (Aesthetic & Soft Neon)
  static const Color accentBlue = Color(0xFF4EA8DE); // soft ocean blue
  static const Color accentPurple = Color(0xFF9D4EDD); // neon violet
  static const Color accentTeal = Color(0xFF2DD4BF); // mint-teal glow
  static const Color accentOrange = Color(0xFFFFA559); // aesthetic warm orange
  static const Color accentPink = Color(0xFFFF6EA1); // soft pink glow
  static const Color accentyellow = Color(0xFFFFD25F);
  // Borders / Hairlines
  static const Color divider = Color(0xFF2A2A2A);

  // Success / Error / Warning
  static const Color success = Color(0xFF4ADE80); // pastel green
  static const Color error = Color(0xFFFF5D5D); // soft red
  static const Color warning = Color(0xFFFFC857); // warm yellow
}
