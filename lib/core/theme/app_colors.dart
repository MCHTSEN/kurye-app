import 'package:flutter/material.dart';

/// Brand colors — only primary + secondary + neutral tones.
abstract final class AppColors {
  // ─── Brand ───
  static const primary = Color(0xFF0721E8);
  static const primaryDark = Color(0xFF0519B8);
  static const primaryLight = Color(0xFF3A4FED);
  static const secondary = Color(0xFFC9ED11);
  static const secondaryDark = Color(0xFFB5D40E);

  // ─── Neutral ───
  static const surfaceHigh = Color(0xFFF8FAFC);
  static const surfaceMid = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const textMuted = Color(0xFF64748B);
  static const textPrimary = Color(0xFF0F172A);

  // ─── Gradient presets ───
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF0721E8), Color(0xFF3A4FED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFFC9ED11), Color(0xFFB5D40E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
