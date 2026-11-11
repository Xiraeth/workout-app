import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Anything tappable: shrinks slightly while pressed and shows a soft overlay.
/// Disabled when both [onTap] and [onLongPress] are null.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.decoration,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    this.overlay,
    this.scale = 0.97,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final BoxDecoration? decoration;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? overlay;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _enabled ? (_) => _set(true) : null,
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: widget.decoration ?? const BoxDecoration(),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: widget.borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: widget.borderRadius,
              splashFactory: NoSplash.splashFactory,
              highlightColor: widget.overlay ?? AppColors.inkAlpha(0.05),
              hoverColor: widget.overlay ?? AppColors.inkAlpha(0.03),
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

enum BtnVariant {
  /// Indigo gradient with a glow.
  primary,

  /// Indigo tint with indigo text.
  tonal,

  /// White with a soft shadow.
  neutral,

  /// Text only.
  ghost,

  /// Solid coral, for destructive confirmations.
  danger,

  /// Green tint, for "done" states.
  success,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BtnVariant.neutral,
    this.icon,
    this.block = false,
    this.height = 44,
    this.fontSize = 15,
    this.foreground,
    this.radius = Radii.button,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final BtnVariant variant;
  final IconData? icon;
  final bool block;
  final double height;
  final double fontSize;
  final Color? foreground;
  final double radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final (BoxDecoration deco, Color fg, Color overlay) = switch (variant) {
      BtnVariant.primary => (
          BoxDecoration(gradient: accentGradient, borderRadius: r, boxShadow: onPressed == null ? null : Shadows.glow(AppColors.accent)),
          Colors.white,
          Colors.white.withValues(alpha: 0.12),
        ),
      BtnVariant.tonal => (BoxDecoration(color: AppColors.accentTint, borderRadius: r), AppColors.accentDark, AppColors.accent.withValues(alpha: 0.08)),
      BtnVariant.neutral => (
          BoxDecoration(color: AppColors.surface, borderRadius: r, boxShadow: Shadows.small),
          AppColors.ink,
          AppColors.inkAlpha(0.05),
        ),
      BtnVariant.ghost => (BoxDecoration(borderRadius: r), AppColors.accent, AppColors.accent.withValues(alpha: 0.08)),
      BtnVariant.danger => (
          BoxDecoration(color: AppColors.missed, borderRadius: r, boxShadow: Shadows.glow(AppColors.missed)),
          Colors.white,
          Colors.white.withValues(alpha: 0.12),
        ),
      BtnVariant.success => (BoxDecoration(color: AppColors.doneTint, borderRadius: r), AppColors.doneText, AppColors.done.withValues(alpha: 0.08)),
    };
    final color = foreground ?? fg;

    final button = Pressable(
      onTap: onPressed,
      decoration: deco,
      borderRadius: r,
      overlay: overlay,
      padding: padding ?? EdgeInsets.symmetric(horizontal: variant == BtnVariant.ghost ? 10 : 16),
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: color), const SizedBox(width: 8)],
            Flexible(
              child: Text(label, overflow: TextOverflow.ellipsis, style: AppText.button.copyWith(fontSize: fontSize, color: color)),
            ),
          ],
        ),
      ),
    );

    final sized = block ? SizedBox(width: double.infinity, child: button) : button;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: onPressed == null ? Opacity(opacity: 0.45, child: sized) : sized,
    );
  }
}

/// Round icon button: white with a soft shadow, or a tint when [tint] is set.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 40,
    this.iconSize = 18,
    this.tint,
    this.iconColor,
    this.flat = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final double iconSize;
  final Color? tint;
  final Color? iconColor; // ink by default
  final bool flat; // no background or shadow

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(size / 2);
    final button = Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        label: tooltip,
        excludeSemantics: true,
        child: Pressable(
          onTap: onPressed,
          scale: 0.92,
          borderRadius: r,
          decoration: flat
              ? null
              : BoxDecoration(color: tint ?? AppColors.surface, borderRadius: r, boxShadow: tint == null ? Shadows.small : null),
          child: SizedBox(width: size, height: size, child: Icon(icon, size: iconSize, color: iconColor ?? AppColors.ink)),
        ),
      ),
    );
    return onPressed == null ? Opacity(opacity: 0.4, child: button) : button;
  }
}
