import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum BtnVariant { primary, secondary, ghost }

/// Flat, square button. Full-width ([block]) buttons keep their label left-aligned.
/// Disabled (onPressed == null) shows the enabled look at 45% opacity.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BtnVariant.secondary,
    this.icon,
    this.iconSize = 16,
    this.block = false,
    this.height,
    this.fontSize = 14,
    this.foreground,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final BtnVariant variant;
  final IconData? icon;
  final double iconSize;
  final bool block;
  final double? height;
  final double fontSize;
  final Color? foreground;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, overlay, side) = switch (variant) {
      BtnVariant.primary => (
          WidgetStateProperty.resolveWith<Color?>((s) => s.contains(WidgetState.pressed)
              ? AppColors.accent700
              : s.contains(WidgetState.hovered)
                  ? AppColors.accent600
                  : AppColors.accent),
          AppColors.bg,
          const WidgetStatePropertyAll<Color?>(Colors.transparent),
          BorderSide.none,
        ),
      BtnVariant.secondary => (
          const WidgetStatePropertyAll<Color?>(Colors.transparent),
          AppColors.ink,
          _overlay(AppColors.ink, 0.07, 0.14),
          const BorderSide(color: AppColors.divider),
        ),
      BtnVariant.ghost => (
          const WidgetStatePropertyAll<Color?>(Colors.transparent),
          AppColors.accent,
          _overlay(AppColors.accent, 0.10, 0.18),
          BorderSide.none,
        ),
    };
    final fgColor = foreground ?? fg;

    final style = ButtonStyle(
      backgroundColor: bg,
      foregroundColor: WidgetStatePropertyAll(fgColor),
      overlayColor: overlay,
      side: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.focused) ? const BorderSide(color: AppColors.accent, width: 2) : side),
      shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
      elevation: const WidgetStatePropertyAll(0),
      padding: WidgetStatePropertyAll(padding ??
          EdgeInsets.symmetric(horizontal: variant == BtnVariant.ghost ? Space.s1 : 14.4, vertical: Space.s2)),
      minimumSize: WidgetStatePropertyAll(Size(0, height ?? 36)),
      fixedSize: height != null ? WidgetStatePropertyAll(Size.fromHeight(height!)) : null,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: block ? Alignment.centerLeft : Alignment.center,
      textStyle: WidgetStatePropertyAll(AppText.button.copyWith(fontSize: fontSize)),
      splashFactory: NoSplash.splashFactory,
    );

    final child = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: iconSize, color: fgColor), const SizedBox(width: 6)],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );

    // The style ignores the disabled state, so a disabled button keeps its colours and the opacity dims it.
    final button = TextButton(onPressed: onPressed, style: style, child: child);

    final sized = block ? SizedBox(width: double.infinity, child: button) : button;
    return onPressed == null ? Opacity(opacity: 0.45, child: sized) : sized;
  }
}

WidgetStateProperty<Color?> _overlay(Color c, double hover, double pressed) => WidgetStateProperty.resolveWith((s) {
      if (s.contains(WidgetState.pressed)) return c.withValues(alpha: pressed);
      if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) return c.withValues(alpha: hover);
      return null;
    });

/// 36×36 square icon button.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.bordered = false,
    this.size = 18,
    this.pressedBg,
    this.pressedFg,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool bordered;
  final double size;
  final Color? pressedBg;
  final Color? pressedFg;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((s) {
        if (pressedBg != null && (s.contains(WidgetState.pressed) || s.contains(WidgetState.hovered))) return pressedBg;
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((s) {
        if (pressedFg != null && (s.contains(WidgetState.pressed) || s.contains(WidgetState.hovered))) return pressedFg;
        return AppColors.ink;
      }),
      overlayColor: pressedBg != null ? const WidgetStatePropertyAll(Colors.transparent) : _overlay(AppColors.ink, 0.07, 0.14),
      side: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.focused)
          ? const BorderSide(color: AppColors.accent, width: 2)
          : bordered
              ? const BorderSide(color: AppColors.divider)
              : BorderSide.none),
      shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      fixedSize: const WidgetStatePropertyAll(Size(36, 36)),
      minimumSize: const WidgetStatePropertyAll(Size(36, 36)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      splashFactory: NoSplash.splashFactory,
    );
    final button = IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: style,
      icon: Icon(icon, size: size),
    );
    return onPressed == null ? Opacity(opacity: 0.45, child: button) : button;
  }
}
