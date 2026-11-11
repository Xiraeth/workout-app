import 'package:flutter/widgets.dart';

import '../models/enums.dart';

/// A colour family: a solid colour for fills/icons, a text colour for use on
/// the tint, and a tint for backgrounds.
class Hue {
  const Hue(this.solid, this.text, this.tint);
  final Color solid;
  final Color text;
  final Color tint;

  static Hue get indigo => Palette.current.indigo;
  static Hue get green => Palette.current.green;
  static Hue get coral => Palette.current.coral;
  static Hue get violet => Palette.current.violet;
  static Hue get sky => Palette.current.sky;
  static Hue get orange => Palette.current.orange;
  static Hue get pink => Palette.current.pink;
  static Hue get amber => Palette.current.amber;
}

/// All colours for one appearance. [current] is swapped by the app root when
/// the appearance setting or the phone's theme changes.
class Palette {
  const Palette({
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.field,
    required this.line,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.accentTint,
    required this.scrim,
    required this.shadow,
    required this.indigo,
    required this.green,
    required this.coral,
    required this.violet,
    required this.sky,
    required this.orange,
    required this.pink,
    required this.amber,
  });

  final bool isDark;
  final Color bg; // page
  final Color surface; // cards, sheets
  final Color field; // inputs, segmented-control tracks
  final Color line; // hairlines and borders
  final Color ink; // main text
  final Color muted; // secondary text
  final Color faint; // placeholders, chevrons
  final Color accent; // brand indigo, fills
  final Color accentLight; // gradient start
  final Color accentDark; // indigo text on tints and page
  final Color accentTint; // tonal fills
  final Color scrim;
  final Color shadow; // base colour of card shadows
  final Hue indigo, green, coral, violet, sky, orange, pink, amber;

  static const light = Palette(
    isDark: false,
    bg: Color(0xFFF4F5FA),
    surface: Color(0xFFFFFFFF),
    field: Color(0xFFEEF0F6),
    line: Color(0xFFE3E6EF),
    ink: Color(0xFF161A2B),
    muted: Color(0xFF6B7085),
    faint: Color(0xFF9EA3B5),
    accent: Color(0xFF4F46E5),
    accentLight: Color(0xFF6366F1),
    accentDark: Color(0xFF4338CA),
    accentTint: Color(0xFFEEF0FF),
    scrim: Color(0x66161A2B),
    shadow: Color(0xFF161A2B),
    indigo: Hue(Color(0xFF4F46E5), Color(0xFF4338CA), Color(0xFFEEF0FF)),
    green: Hue(Color(0xFF16A34A), Color(0xFF15803D), Color(0xFFE7F8EE)),
    coral: Hue(Color(0xFFF04438), Color(0xFFB42318), Color(0xFFFEF0EF)),
    violet: Hue(Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFFF3EEFF)),
    sky: Hue(Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFFE6F4FC)),
    orange: Hue(Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFFFFF1E8)),
    pink: Hue(Color(0xFFDB2777), Color(0xFFBE185D), Color(0xFFFDEEF5)),
    amber: Hue(Color(0xFFD97706), Color(0xFFB45309), Color(0xFFFEF5E7)),
  );

  /// Deep navy page, slightly lighter cards; hues get brighter solids, light
  /// text shades and dark, low-saturation tints.
  static const dark = Palette(
    isDark: true,
    bg: Color(0xFF0D0F17),
    surface: Color(0xFF171A26),
    field: Color(0xFF222636),
    line: Color(0xFF2B3045),
    ink: Color(0xFFECEEF6),
    muted: Color(0xFF9AA0B8),
    faint: Color(0xFF666C85),
    accent: Color(0xFF6366F1),
    accentLight: Color(0xFF818CF8),
    accentDark: Color(0xFFA5B4FC),
    accentTint: Color(0xFF1F2247),
    scrim: Color(0x99000000),
    shadow: Color(0xFF000000),
    indigo: Hue(Color(0xFF6366F1), Color(0xFFA5B4FC), Color(0xFF1F2247)),
    green: Hue(Color(0xFF22C55E), Color(0xFF86EFAC), Color(0xFF12291D)),
    coral: Hue(Color(0xFFF97066), Color(0xFFFDA29B), Color(0xFF331A1A)),
    violet: Hue(Color(0xFF8B5CF6), Color(0xFFC4B5FD), Color(0xFF241B3D)),
    sky: Hue(Color(0xFF0EA5E9), Color(0xFF7DD3FC), Color(0xFF0F2535)),
    orange: Hue(Color(0xFFF97316), Color(0xFFFDBA74), Color(0xFF2F1D10)),
    pink: Hue(Color(0xFFEC4899), Color(0xFFF9A8D4), Color(0xFF2F1626)),
    amber: Hue(Color(0xFFF59E0B), Color(0xFFFCD34D), Color(0xFF2C2210)),
  );

  static Palette current = light;
}

/// The active palette's colours by name.
abstract final class AppColors {
  static Palette get _p => Palette.current;
  static Color get bg => _p.bg;
  static Color get surface => _p.surface;
  static Color get field => _p.field;
  static Color get line => _p.line;
  static Color get ink => _p.ink;
  static Color get muted => _p.muted;
  static Color get faint => _p.faint;
  static Color get accent => _p.accent;
  static Color get accentLight => _p.accentLight;
  static Color get accentDark => _p.accentDark;
  static Color get accentTint => _p.accentTint;
  static Color get done => _p.green.solid;
  static Color get doneText => _p.green.text;
  static Color get doneTint => _p.green.tint;
  static Color get missed => _p.coral.solid;
  static Color get missedText => _p.coral.text;
  static Color get missedTint => _p.coral.tint;
  static Color get scrim => _p.scrim;

  static Color inkAlpha(double a) => ink.withValues(alpha: a);
}

/// Body parts are coloured by group: push, pull, core, legs, full body.
Hue hueForPart(BodyPart p) => switch (p) {
      BodyPart.chest || BodyPart.shoulders || BodyPart.triceps => Hue.violet,
      BodyPart.back || BodyPart.biceps || BodyPart.forearms => Hue.sky,
      BodyPart.core => Hue.pink,
      BodyPart.glutes || BodyPart.quads || BodyPart.hamstrings || BodyPart.calves => Hue.orange,
      BodyPart.fullBody => Hue.indigo,
    };

Hue hueForStatus(SessionStatus s) => switch (s) {
      SessionStatus.done => Hue.green,
      SessionStatus.planned => Hue.indigo,
      SessionStatus.missed => Hue.coral,
    };

abstract final class Space {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const side = 20.0;
}

abstract final class Radii {
  static const card = 20.0;
  static const tile = 16.0;
  static const button = 16.0;
  static const field = 14.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

abstract final class Shadows {
  /// Soft lift for cards. In dark mode the lighter card colour does most of the
  /// work, and the shadow is darker and tighter.
  static List<BoxShadow> get card => Palette.current.isDark
      ? const [BoxShadow(color: Color(0x59000000), blurRadius: 18, offset: Offset(0, 6))]
      : [
          BoxShadow(color: Palette.current.shadow.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: Palette.current.shadow.withValues(alpha: 0.04), blurRadius: 3, offset: const Offset(0, 1)),
        ];

  /// Small lift for round icon buttons and pills.
  static List<BoxShadow> get small => [
        BoxShadow(color: Palette.current.shadow.withValues(alpha: Palette.current.isDark ? 0.35 : 0.08), blurRadius: 10, offset: const Offset(0, 3)),
      ];

  /// Coloured glow under a primary gradient.
  static List<BoxShadow> glow(Color c) => [
        BoxShadow(color: c.withValues(alpha: Palette.current.isDark ? 0.45 : 0.35), blurRadius: 20, offset: const Offset(0, 8)),
      ];
}

/// Gradients for primary fills.
LinearGradient fillGradient(Color light, Color dark) =>
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [light, dark]);

LinearGradient get accentGradient => fillGradient(AppColors.accentLight, AppColors.accent);

abstract final class AppText {
  static const family = 'PlusJakartaSans';

  static TextStyle _s(double size, FontWeight w, {double? height, double em = 0, Color? color}) =>
      TextStyle(fontFamily: family, fontSize: size, fontWeight: w, height: height, letterSpacing: em * size, color: color ?? AppColors.ink);

  static TextStyle get h1 => _s(32, FontWeight.w800, height: 1.15, em: -0.02);
  static TextStyle get h2 => _s(28, FontWeight.w800, height: 1.15, em: -0.02);
  static TextStyle get h3 => _s(20, FontWeight.w800, height: 1.2, em: -0.01);
  static TextStyle get h4 => _s(18, FontWeight.w700, height: 1.25, em: -0.01);
  static TextStyle get title => _s(17, FontWeight.w700, height: 1.3);
  static TextStyle get body => _s(15, FontWeight.w500, height: 1.45);
  static TextStyle get small => _s(13, FontWeight.w500, height: 1.4, color: AppColors.muted);
  static TextStyle get tiny => _s(12, FontWeight.w500, height: 1.35, color: AppColors.muted);
  static TextStyle get label => _s(13, FontWeight.w600, color: AppColors.muted);
  static TextStyle get button => _s(15, FontWeight.w700, height: 1.2);
  static TextStyle get input => _s(16, FontWeight.w600);
  static TextStyle get overline => _s(11, FontWeight.w700, em: 0.08, color: Palette.current.isDark ? AppColors.accentDark : AppColors.accent);
  static TextStyle get badge => _s(12, FontWeight.w700, height: 1.2);
}
