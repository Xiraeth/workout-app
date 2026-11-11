import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/enums.dart';
import '../models/exercise.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import 'app_buttons.dart';

/// White rounded card with a soft shadow; tappable when [onTap] is set.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16), this.color, this.radius = Radii.card});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color; // defaults to the surface colour, with a shadow
  final double radius;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final deco = BoxDecoration(color: color ?? AppColors.surface, borderRadius: r, boxShadow: color == null ? Shadows.card : null);
    if (onTap == null) return Container(decoration: deco, padding: padding, child: child);
    return Pressable(onTap: onTap, decoration: deco, borderRadius: r, padding: padding, scale: 0.98, child: child);
  }
}

/// Done / Planned / Missed pill.
class StatusTag extends StatelessWidget {
  const StatusTag(this.status, {super.key});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final h = hueForStatus(status);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(color: h.tint, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: h.solid, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status.label, style: AppText.badge.copyWith(color: h.text)),
        ],
      ),
    );
  }
}

/// A small tinted pill, e.g. "TODAY".
class TintPill extends StatelessWidget {
  const TintPill(this.text, {super.key, this.hue});

  final String text;
  final Hue? hue; // indigo by default

  @override
  Widget build(BuildContext context) {
    final hue = this.hue ?? Hue.indigo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: hue.tint, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Text(text, style: AppText.badge.copyWith(color: hue.text, fontSize: 11, letterSpacing: 0.6)),
    );
  }
}

/// Field label with optional trailing hint.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(text, style: AppText.label)),
          if (trailing != null) Text(trailing!, style: AppText.tiny.copyWith(color: AppColors.faint)),
        ],
      ),
    );
  }
}

/// Section heading with an optional trailing note.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(text, style: AppText.h4)),
          if (trailing != null) Text(trailing!, style: AppText.small),
        ],
      ),
    );
  }
}

/// Filled, rounded 48px input; indigo ring when focused.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.semanticLabel,
    this.height = 48,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? semanticLabel;
  final double height;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        textAlign: textAlign,
        style: AppText.input,
        expands: true,
        maxLines: null,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(hintText: hint),
      ),
    );
    return semanticLabel == null ? field : Semantics(label: semanticLabel, child: field);
  }
}

/// Pill segmented control: a grey track with a sliding indigo pill.
class SegControl<T> extends StatelessWidget {
  const SegControl({super.key, required this.options, required this.value, required this.onChanged, required this.labelOf});

  final List<T> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    final index = options.indexOf(value);
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(Radii.pill)),
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth / options.length;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              left: w * index,
              top: 0,
              bottom: 0,
              width: w,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: accentGradient,
                  borderRadius: BorderRadius.circular(Radii.pill),
                  boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
                ),
              ),
            ),
            Row(
              children: [
                for (final o in options)
                  Expanded(
                    child: Semantics(
                      selected: o == value,
                      inMutuallyExclusiveGroup: true,
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(o),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: AppText.body.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: o == value ? Colors.white : AppColors.muted,
                            ),
                            child: Text(labelOf(o)),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

/// Pill chip. Selected chips fill with [hue].
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.hue,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Hue? hue; // indigo by default
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(Radii.pill);
    final hue = this.hue ?? Hue.indigo;
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: r,
        scale: 0.94,
        decoration: BoxDecoration(
          color: selected ? hue.solid : AppColors.surface,
          borderRadius: r,
          border: Border.all(color: selected ? hue.solid : AppColors.line),
          boxShadow: selected ? [BoxShadow(color: hue.solid.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(0, 3))] : null,
        ),
        padding: compact ? const EdgeInsets.symmetric(horizontal: 12, vertical: 7) : const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!selected && !compact) ...[
              Container(width: 7, height: 7, decoration: BoxDecoration(color: hue.solid, shape: BoxShape.circle)),
              const SizedBox(width: 7),
            ],
            if (selected) ...[
              const Icon(LucideIcons.check, size: 14, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppText.body.copyWith(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filled circle with a number, e.g. exercise and set indexes.
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.number, {super.key, this.size = 30, this.hue, this.filled = true});

  final int number;
  final double size;
  final Hue? hue; // indigo by default
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final hue = this.hue ?? Hue.indigo;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: filled ? fillGradient(Color.lerp(hue.solid, Colors.white, 0.15)!, hue.solid) : null,
        color: filled ? null : hue.tint,
        shape: BoxShape.circle,
      ),
      child: Text('$number', style: AppText.badge.copyWith(fontSize: size * 0.43, color: filled ? Colors.white : hue.text)),
    );
  }
}

/// Rounded square tile with a gradient and a white icon.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, required this.hue, this.size = 44});

  final IconData icon;
  final Hue hue;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: fillGradient(Color.lerp(hue.solid, Colors.white, 0.25)!, hue.solid),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [BoxShadow(color: hue.solid.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Icon(icon, size: size * 0.48, color: Colors.white),
    );
  }
}

/// Bottom area holding a screen's main action, above the navigation bar.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bg.withValues(alpha: 0), AppColors.bg, AppColors.bg],
          stops: const [0, 0.25, 1],
        ),
      ),
      padding: EdgeInsets.fromLTRB(Space.side, 16, Space.side, bottomGap(context, min: 20)),
      child: child,
    );
  }
}

/// Space under the last control on a screen or sheet: [min], or the system
/// navigation bar's height plus 12 when that is larger.
double bottomGap(BuildContext context, {double min = 24}) {
  final inset = MediaQuery.viewPaddingOf(context).bottom;
  return inset + 12 > min ? inset + 12 : min;
}

/// Grab handle at the top of a bottom sheet.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 4),
        width: 40,
        height: 5,
        decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(Radii.pill)),
      ),
    );
  }
}

/// "Last time  3 × 8 · 60 kg": an exercise's sets in the session it was copied from.
class LastTime extends StatelessWidget {
  const LastTime({super.key, required this.previous, required this.unit});

  final Exercise previous;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(LucideIcons.history, size: 13, color: AppColors.muted),
        const SizedBox(width: 5),
        Text('Last time  ', style: AppText.tiny.copyWith(fontWeight: FontWeight.w700)),
        Expanded(child: Text(setSummary(previous, unit), overflow: TextOverflow.ellipsis, style: AppText.tiny)),
      ],
    );
  }
}
