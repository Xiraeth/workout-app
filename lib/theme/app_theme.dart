import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Flat, Swiss-modernist theme: radius 0, no shadows, no ripples.
ThemeData buildAppTheme() {
  const square = RoundedRectangleBorder();
  final scheme = ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: AppColors.bg,
    secondary: AppColors.accent,
    onSecondary: AppColors.bg,
    surface: AppColors.bg,
    onSurface: AppColors.ink,
    surfaceContainerHighest: AppColors.surface,
    outline: AppColors.divider,
    error: AppColors.accent700,
  );

  final inputBorder = WidgetStateInputBorder.resolveWith((states) {
    final color = states.contains(WidgetState.focused)
        ? AppColors.accent
        : states.contains(WidgetState.hovered)
            ? AppColors.inkAlpha(0.45)
            : AppColors.divider;
    return OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: color));
  });

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: AppText.family);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    splashFactory: NoSplash.splashFactory,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
    textTheme: base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink, fontFamily: AppText.family),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: AppColors.accentAlpha(0.3),
      selectionHandleColor: AppColors.accent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hoverColor: Colors.transparent,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      hintStyle: AppText.input.copyWith(color: AppColors.inkAlpha(0.35)),
      border: inputBorder,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        shape: square,
        textStyle: AppText.button,
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.bg,
      modalBackgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: square,
      clipBehavior: Clip.hardEdge,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: square,
      barrierColor: AppColors.scrim,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: square,
      headerBackgroundColor: AppColors.ink,
      headerForegroundColor: AppColors.bg,
      dayShape: const WidgetStatePropertyAll(square),
      yearShape: const WidgetStatePropertyAll(square),
      todayBorder: const BorderSide(color: AppColors.accent),
      dividerColor: AppColors.divider,
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.accent700, shape: square, textStyle: AppText.button),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.accent700, shape: square, textStyle: AppText.button),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
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
