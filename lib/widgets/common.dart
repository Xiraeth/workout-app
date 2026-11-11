import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/enums.dart';
import '../theme/tokens.dart';

/// Done / Planned / Missed tag.
class StatusTag extends StatelessWidget {
  const StatusTag(this.status, {super.key});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (status) {
      SessionStatus.done => (AppColors.accent100, AppColors.accent800, null),
      SessionStatus.planned => (Colors.transparent, AppColors.accent, Border.all(color: AppColors.accent)),
      SessionStatus.missed => (AppColors.neutral100, AppColors.neutral800, null),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, border: border),
      child: Text(status.label, style: AppText.tag.copyWith(color: fg)),
    );
  }
}

/// Field label: 12px, ink @ 70%, 5px below.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(text, style: AppText.label)),
          if (trailing != null) Text(trailing!, style: AppText.muted12),
        ],
      ),
    );
  }
}

/// 44px input: surface fill, 1px divider border, accent when focused.
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
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        style: AppText.input,
        expands: true,
        maxLines: null,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
      ),
    );
    return semanticLabel == null ? field : Semantics(label: semanticLabel, child: field);
  }
}

/// Full-width segmented control with two or more equal segments.
class SegControl<T> extends StatelessWidget {
  const SegControl({super.key, required this.options, required this.value, required this.onChanged, required this.labelOf});

  final List<T> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.divider)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, o) in options.indexed) ...[
              if (i > 0) Container(width: 1, color: AppColors.divider),
              Expanded(child: _Segment(label: labelOf(o), selected: o == value, onTap: () => onChanged(o))),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: selected ? AppColors.accent : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: selected ? Colors.transparent : AppColors.inkAlpha(0.14),
          hoverColor: selected ? Colors.transparent : AppColors.inkAlpha(0.07),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(label,
                    style: AppText.body.copyWith(fontSize: 13, height: 1.2, color: selected ? AppColors.bg : AppColors.ink)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square chip used for body parts (toggle) and quick picks.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.selectedColor = AppColors.accent,
    this.selectedBorder = AppColors.accent,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color selectedColor;
  final Color selectedBorder;
  final bool compact; // quick-pick size

  @override
  Widget build(BuildContext context) {
    final style = compact
        ? AppText.body.copyWith(fontSize: 12, height: 1.2)
        : AppText.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? selectedColor : Colors.transparent,
        shape: Border.all(color: selected ? selectedBorder : AppColors.divider),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashFactory: NoSplash.splashFactory,
          highlightColor: selected ? Colors.transparent : AppColors.inkAlpha(0.14),
          hoverColor: selected ? Colors.transparent : AppColors.inkAlpha(0.07),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: compact ? 0 : 36),
            child: Padding(
              padding: compact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6) : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(label, style: style.copyWith(color: selected ? AppColors.bg : AppColors.ink)),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tappable list row with a 1px bottom rule and an ink @ 4% pressed overlay.
class RuledRow extends StatelessWidget {
  const RuledRow({super.key, required this.onTap, required this.child, this.padding = const EdgeInsets.symmetric(vertical: 12)});

  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: AppColors.inkAlpha(0.04),
        hoverColor: AppColors.inkAlpha(0.04),
        child: Container(
          decoration: const BoxDecoration(border: Border(bottom: Rule.thinSide)),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Bottom bar with a 2px top rule; padding 12/20 and [bottomGap] below.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: Rule.thickSide)),
      padding: EdgeInsets.fromLTRB(Space.side, 12, Space.side, bottomGap(context)),
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
