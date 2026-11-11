import 'package:flutter/widgets.dart';

import '../models/enums.dart';

/// Light theme colours: cool neutrals, an indigo brand colour, and status /
/// body-part colours for meaning.
abstract final class AppColors {
  static const bg = Color(0xFFF4F5FA); // page
  static const surface = Color(0xFFFFFFFF); // cards, sheets
  static const field = Color(0xFFEEF0F6); // inputs, segmented-control tracks
  static const line = Color(0xFFE3E6EF); // hairlines and borders
  static const ink = Color(0xFF161A2B); // main text
  static const muted = Color(0xFF6B7085); // secondary text
  static const faint = Color(0xFF9EA3B5); // placeholders, disabled

  static const accent = Color(0xFF4F46E5); // indigo 600
  static const accentLight = Color(0xFF6366F1); // indigo 500, gradient start
  static const accentDark = Color(0xFF4338CA); // indigo 700, small text
  static const accentTint = Color(0xFFEEF0FF); // indigo 50
  static const accentTint2 = Color(0xFFE0E4FF); // indigo 100

  static const done = Color(0xFF16A34A);
  static const doneText = Color(0xFF15803D);
  static const doneTint = Color(0xFFE7F8EE);

  static const missed = Color(0xFFF04438);
  static const missedText = Color(0xFFB42318);
  static const missedTint = Color(0xFFFEF0EF);

  static const amber = Color(0xFFD97706);
  static const amberTint = Color(0xFFFEF5E7);

  static const scrim = Color(0x66161A2B);

  static Color inkAlpha(double a) => ink.withValues(alpha: a);
}

/// A colour family: a solid colour for fills/icons, a darker one for text on
/// the tint, and a light tint for backgrounds.
class Hue {
  const Hue(this.solid, this.text, this.tint);
  final Color solid;
  final Color text;
  final Color tint;

  static const indigo = Hue(AppColors.accent, AppColors.accentDark, AppColors.accentTint);
  static const green = Hue(AppColors.done, AppColors.doneText, AppColors.doneTint);
  static const coral = Hue(AppColors.missed, AppColors.missedText, AppColors.missedTint);
  static const violet = Hue(Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFFF3EEFF));
  static const sky = Hue(Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFFE6F4FC));
  static const orange = Hue(Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFFFFF1E8));
  static const pink = Hue(Color(0xFFDB2777), Color(0xFFBE185D), Color(0xFFFDEEF5));
  static const amber = Hue(AppColors.amber, Color(0xFFB45309), AppColors.amberTint);
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
  /// Soft lift for cards.
  static const card = [
    BoxShadow(color: Color(0x0F161A2B), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A161A2B), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// Small lift for round icon buttons and pills.
  static const small = [
    BoxShadow(color: Color(0x14161A2B), blurRadius: 10, offset: Offset(0, 3)),
  ];

  /// Coloured glow under a primary gradient.
  static List<BoxShadow> glow(Color c) => [
        BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
      ];
}

/// Gradients for primary fills.
LinearGradient fillGradient(Color light, Color dark) =>
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [light, dark]);

final accentGradient = fillGradient(AppColors.accentLight, AppColors.accent);

abstract final class AppText {
  static const family = 'PlusJakartaSans';

  static TextStyle _s(double size, FontWeight w, {double? height, double em = 0, Color color = AppColors.ink}) =>
      TextStyle(fontFamily: family, fontSize: size, fontWeight: w, height: height, letterSpacing: em * size, color: color);

  static final h1 = _s(32, FontWeight.w800, height: 1.15, em: -0.02);
  static final h2 = _s(28, FontWeight.w800, height: 1.15, em: -0.02);
  static final h3 = _s(20, FontWeight.w800, height: 1.2, em: -0.01);
  static final h4 = _s(18, FontWeight.w700, height: 1.25, em: -0.01);
  static final title = _s(17, FontWeight.w700, height: 1.3);
  static final body = _s(15, FontWeight.w500, height: 1.45);
  static final small = _s(13, FontWeight.w500, height: 1.4, color: AppColors.muted);
  static final tiny = _s(12, FontWeight.w500, height: 1.35, color: AppColors.muted);
  static final label = _s(13, FontWeight.w600, color: AppColors.muted);
  static final button = _s(15, FontWeight.w700, height: 1.2);
  static final input = _s(16, FontWeight.w600);
  static final overline = _s(11, FontWeight.w700, em: 0.08, color: AppColors.accent);
  static final badge = _s(12, FontWeight.w700, height: 1.2);
}
