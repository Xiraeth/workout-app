import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Light, rounded theme. Most components are custom widgets; this covers the
/// Material pieces still in use (text fields, date picker, sheets, dialogs).
ThemeData buildAppTheme() {
  RoundedRectangleBorder rounded(double r) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
  final scheme = ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    surfaceContainerHighest: AppColors.field,
    surfaceContainerHigh: AppColors.surface,
    outline: AppColors.line,
    error: AppColors.missed,
  );

  final fieldBorder = WidgetStateInputBorder.resolveWith((states) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: states.contains(WidgetState.focused)
            ? const BorderSide(color: AppColors.accent, width: 2)
            : BorderSide.none,
      ));

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: AppText.family);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    splashFactory: NoSplash.splashFactory,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textTheme: base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink, fontFamily: AppText.family),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: AppColors.accent.withValues(alpha: 0.25),
      selectionHandleColor: AppColors.accent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.field,
      hoverColor: Colors.transparent,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      hintStyle: AppText.input.copyWith(color: AppColors.faint),
      border: fieldBorder,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent, textStyle: AppText.button, shape: rounded(12)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.bg,
      modalBackgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet))),
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: rounded(24),
      barrierColor: AppColors.scrim,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: rounded(24),
      headerBackgroundColor: AppColors.accent,
      headerForegroundColor: Colors.white,
      todayBorder: const BorderSide(color: AppColors.accent),
      dividerColor: AppColors.line,
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.muted, textStyle: AppText.button),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.accent, textStyle: AppText.button),
    ),
    appBarTheme: const AppBarTheme(systemOverlayStyle: overlayStyle),
  );
}

const overlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  // Draw behind the navigation bar (edge to edge) without Android's contrast scrim;
  // screens pad their bottom bars by the system inset.
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarContrastEnforced: false,
  systemStatusBarContrastEnforced: false,
);
