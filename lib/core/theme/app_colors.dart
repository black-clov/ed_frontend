import 'package:flutter/material.dart';

/// Central brand palette for Eidmaj — only 3 brand colors (from the logo):
/// RED (Employment track + errors/danger), GREEN (Entrepreneurship track),
/// and WHITE surfaces, plus neutral text/background tones.
///
/// Do NOT introduce new hues (no blue/purple/teal/orange). Employment-track
/// screens use the red family; Entrepreneurship-track screens use the green
/// family. Red is also the semantic color for errors and destructive actions.
class AppColors {
  AppColors._();

  // ── Brand: RED (Employment + danger) ──────────────────────────────
  static const Color red = Color(0xFFC62828);
  static const Color redDark = Color(0xFFB71C1C);
  static const Color redLight = Color(0xFFE53935);
  static const Color redTint = Color(0xFFFFEBEE);

  // ── Brand: GREEN (Entrepreneurship) ───────────────────────────────
  static const Color green = Color(0xFF2E7D32);
  static const Color greenDark = Color(0xFF1B5E20);
  static const Color greenLight = Color(0xFF43A047);
  static const Color greenTint = Color(0xFFE8F5E9);

  // ── Neutrals ──────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAF6F0); // warm off-white app bg
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textMuted = Color(0xFF8D6E63);
  static const Color border = Color(0xFFE7DDD0);
}
