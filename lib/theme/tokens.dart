import 'package:flutter/widgets.dart';

/// Colours from the design handoff. Small accent text uses [accent700].
abstract final class AppColors {
  static const bg = Color(0xFFF3F2F2);
  static const surface = Color(0xFFEAE9E9);
  static const ink = Color(0xFF201E1D);
  static const divider = Color(0x66201E1D); // ink @ 40%
  static final muted = ink.withValues(alpha: 0.55);
  static final label = ink.withValues(alpha: 0.70);

  static const accent = Color(0xFF4B3BC4);
  static const accent100 = Color(0xFFF2F0FD);
  static const accent200 = Color(0xFFE1DDFA);
  static const accent300 = Color(0xFFC7C0F4);
  static const accent400 = Color(0xFF9D92EA);
  static const accent500 = Color(0xFF6A5BDC);
  static const accent600 = Color(0xFF3E2FA8);
  static const accent700 = Color(0xFF30238A);
  static const accent800 = Color(0xFF231A66);
  static const accent900 = Color(0xFF171142);

  static const neutral100 = Color(0xFFF8F4F4);
  static const neutral300 = Color(0xFFD7D3D3);
  static const neutral800 = Color(0xFF444141);
  static const neutral900 = Color(0xFF2D2B2B);
  static final scrim = neutral900.withValues(alpha: 0.5);

  static Color inkAlpha(double a) => ink.withValues(alpha: a);
  static Color accentAlpha(double a) => accent.withValues(alpha: a);
}

/// Spacing scale: 4 / 8 / 12 / 16 / 24 / 32. Screen side padding is 20.
abstract final class Space {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const side = 20.0;
}

abstract final class Rule {
  static const thick = 2.0;
  static const thin = 1.0;
  static const BorderSide thickSide = BorderSide(color: AppColors.divider, width: thick);
  static const BorderSide thinSide = BorderSide(color: AppColors.divider, width: thin);
}

/// Text styles. Letter spacing in the spec is in em; converted here to logical pixels.
abstract final class AppText {
  static const family = 'Archivo';

  static TextStyle _s(double size, FontWeight w, {double? height, double em = 0, Color color = AppColors.ink}) =>
      TextStyle(fontFamily: family, fontSize: size, fontWeight: w, height: height, letterSpacing: em * size, color: color);

  static final h1 = _s(42, FontWeight.w800, height: 1.12, em: -0.015);
  static final h2 = _s(32, FontWeight.w800, height: 1.12, em: -0.015);
  static final h4 = _s(20, FontWeight.w800, height: 1.12, em: -0.015);
  static final h6 = _s(13, FontWeight.w800, height: 1.12, em: 0.08); // uppercase the string
  static final cardTitle = _s(20, FontWeight.w800, height: 1.2);
  static final exerciseName = _s(16, FontWeight.w800, height: 1.2);
  static final body = _s(15, FontWeight.w400, height: 1.55);
  static final button = _s(14, FontWeight.w800, height: 1.2);
  static final input = _s(16, FontWeight.w600);
  static final label = _s(12, FontWeight.w400, color: AppColors.label);
  static final muted12 = _s(12, FontWeight.w400, color: AppColors.muted);
  static final muted13 = _s(13, FontWeight.w400, color: AppColors.muted);
  static final tag = _s(11, FontWeight.w400, em: 0.02);

  static TextStyle caps(double size, {FontWeight weight = FontWeight.w600, double em = 0.1, Color color = AppColors.ink}) =>
      _s(size, weight, em: em, color: color);
}
