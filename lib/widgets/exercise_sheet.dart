import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/exercise_template.dart';
import '../models/set_entry.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import 'app_buttons.dart';
import 'common.dart';
import 'delete_dialog.dart';

sealed class ExerciseSheetResult {
  const ExerciseSheetResult();
}

class ExerciseSaved extends ExerciseSheetResult {
  const ExerciseSaved(this.exercise);
  final Exercise exercise;
}

class ExerciseRemoved extends ExerciseSheetResult {
  const ExerciseRemoved();
}

/// Opens the create/edit sheet. Null means cancelled.
Future<ExerciseSheetResult?> showExerciseSheet(BuildContext context, {Exercise? existing, required WeightUnit unit}) =>
    showModalBottomSheet<ExerciseSheetResult>(
      context: context,
      isScrollControlled: true,
      barrierColor: AppColors.scrim,
      // The sheet sits above the keyboard (so the focused field can scroll into
      // view) and takes 94% of the height that's left.
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: FractionallySizedBox(
          heightFactor: 0.94,
          child: ExerciseSheet(existing: existing, unit: unit),
        ),
      ),
    );

class ExerciseSheet extends ConsumerStatefulWidget {
  const ExerciseSheet({super.key, this.existing, required this.unit});

  final Exercise? existing;
  final WeightUnit unit;

  @override
  ConsumerState<ExerciseSheet> createState() => _ExerciseSheetState();
}

class _ExerciseSheetState extends ConsumerState<ExerciseSheet> {
  // Models are immutable, so editing this draft never touches the saved exercise.
  late Exercise _draft = widget.existing ?? Exercise.blank();
  late final _name = TextEditingController(text: _draft.name);

  bool get _isEdit => widget.existing != null;
  bool get _canSave => _draft.name.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _set(Exercise e) => setState(() => _draft = e);

  void _pick(ExerciseTemplate t) {
    _name.value = TextEditingValue(text: t.name, selection: TextSelection.collapsed(offset: t.name.length));
    _set(_draft.copyWith(name: t.name, equipment: t.equipment, measure: t.measure, motion: t.motion));
  }

  Future<void> _forget(ExerciseTemplate t) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Remove "${t.name}"?',
      body: "It won't be offered as a quick pick any more. Sessions that already use it keep it.",
      confirm: 'Remove',
    );
    if (ok == true) ref.read(exerciseLibraryProvider.notifier).remove(t.id);
  }

  void _addSet() {
    final last = _draft.sets.isEmpty ? SetEntry() : _draft.sets.last.duplicate();
    _set(_draft.copyWith(sets: [..._draft.sets, last]));
  }

  void _save() => Navigator.of(context).pop(ExerciseSaved(_draft.copyWith(name: _draft.name.trim())));

  @override
  Widget build(BuildContext context) {
    // With the keyboard open the sheet already ends above it; otherwise keep
    // clear of the navigation bar.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isBw = _draft.equipment == Equipment.bodyweight;
    final isTime = _draft.measure == Measure.time;

    // Typing filters the list; an unknown name will be added on save.
    final library = ref.watch(exerciseLibraryProvider);
    final typed = nameKey(_draft.name);
    final matches = typed.isEmpty ? library : library.where((t) => t.key.contains(typed)).toList();
    final isNew = typed.isNotEmpty && !library.any((t) => t.key == typed);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Cancel | title | Save
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: Rule.thickSide)),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(label: 'Cancel', variant: BtnVariant.ghost, onPressed: () => Navigator.of(context).pop()),
                  ),
                ),
                Text(_isEdit ? 'Edit exercise' : 'New exercise',
                    style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(label: 'Save', variant: BtnVariant.primary, onPressed: _canSave ? _save : null),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(Space.side, 18, Space.side, keyboardOpen ? 28 : bottomGap(context, min: 28)),
              children: [
                const FieldLabel('Exercise'),
                AppTextField(
                  controller: _name,
                  hint: 'e.g. Bench press',
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (v) => _set(_draft.copyWith(name: v)),
                ),
                const SizedBox(height: 20),

                const FieldLabel('Your exercises', trailing: 'Hold to remove'),
                const SizedBox(height: 3),
                if (matches.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in matches)
                        AppChip(
                          label: t.name,
                          compact: true,
                          selected: t.key == typed,
                          selectedColor: AppColors.ink,
                          selectedBorder: AppColors.divider,
                          onTap: () => _pick(t),
                          onLongPress: () => _forget(t),
                        ),
                    ],
                  ),
                if (isNew)
                  Padding(
                    padding: EdgeInsets.only(top: matches.isEmpty ? 0 : 8),
                    child: Text('New exercise. Saving adds it to your exercises.', style: AppText.muted12.copyWith(height: 1.4)),
                  ),
                const SizedBox(height: 20),

                // Type
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(border: Border(top: Rule.thickSide)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FieldLabel('Equipment'),
                      SegControl<Equipment>(
                        options: Equipment.values,
                        value: _draft.equipment,
                        labelOf: (e) => e.label,
                        onChanged: (e) => _set(_draft.copyWith(equipment: e)),
                      ),
                      const SizedBox(height: 12),
                      const FieldLabel('Measured by'),
                      SegControl<Measure>(
                        options: Measure.values,
                        value: _draft.measure,
                        labelOf: (m) => m.label,
                        onChanged: (m) => _set(_draft.copyWith(measure: m)),
                      ),
                      const SizedBox(height: 12),
                      const FieldLabel('Movement'),
                      SegControl<Motion>(
                        options: Motion.values,
                        value: _draft.motion,
                        labelOf: (m) => m.label,
                        // Isometric holds are timed; the user can switch back.
                        onChanged: (m) => _set(_draft.copyWith(motion: m, measure: m == Motion.isometric ? Measure.time : null)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sets
                Container(
                  padding: const EdgeInsets.only(bottom: 6),
                  decoration: const BoxDecoration(border: Border(bottom: Rule.thickSide)),
                  child: _SetGrid(
                    number: const _HeaderText('SET'),
                    value: _HeaderText(isTime ? 'TIME (SEC)' : 'REPS'),
                    weight: _HeaderText(isBw ? 'LOAD' : 'WEIGHT'),
                    action: const SizedBox.shrink(),
                  ),
                ),
                for (final (i, s) in _draft.sets.indexed)
                  _SetRow(
                    key: ValueKey(s.id),
                    number: i + 1,
                    entry: s,
                    isBodyweight: isBw,
                    isTime: isTime,
                    unit: widget.unit,
                    onChanged: (next) => _set(_draft.copyWith(sets: [for (final x in _draft.sets) x.id == next.id ? next : x])),
                    onRemove: _draft.sets.length < 2
                        ? null
                        : () => _set(_draft.copyWith(sets: _draft.sets.where((x) => x.id != s.id).toList())),
                  ),
                const SizedBox(height: 8),
                Text(
                  isBw
                      ? 'BW = your bodyweight. Add a vest or belt load, or leave blank.'
                      : 'Total weight moved per set — bar plus plates, or per dumbbell.',
                  style: AppText.muted12.copyWith(height: 1.4),
                ),
                const SizedBox(height: 12),
                AppButton(label: 'Add set', icon: LucideIcons500.plus, block: true, height: 44, onPressed: _addSet),

                if (_isEdit) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      label: 'Remove exercise from session',
                      variant: BtnVariant.ghost,
                      foreground: AppColors.accent700,
                      onPressed: () => Navigator.of(context).pop(const ExerciseRemoved()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Columns: 28px | 1fr | 1.2fr | 36px, gap 8.
class _SetGrid extends StatelessWidget {
  const _SetGrid({required this.number, required this.value, required this.weight, required this.action});

  final Widget number, value, weight, action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 28, child: number),
        const SizedBox(width: 8),
        Expanded(flex: 10, child: value),
        const SizedBox(width: 8),
        Expanded(flex: 12, child: weight),
        const SizedBox(width: 8),
        SizedBox(width: 36, child: action),
      ],
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caps(11, weight: FontWeight.w400, em: 0.08, color: AppColors.inkAlpha(0.6)));
}

class _SetRow extends StatefulWidget {
  const _SetRow({
    super.key,
    required this.number,
    required this.entry,
    required this.isBodyweight,
    required this.isTime,
    required this.unit,
    required this.onChanged,
    required this.onRemove,
  });

  final int number;
  final SetEntry entry;
  final bool isBodyweight;
  final bool isTime;
  final WeightUnit unit;
  final ValueChanged<SetEntry> onChanged;
  final VoidCallback? onRemove;

  @override
  State<_SetRow> createState() => _SetRowState();
}

final _weightPattern = RegExp(r'^\d{0,4}([.,]\d{0,2})?$');

class _SetRowState extends State<_SetRow> {
  late final _value = TextEditingController(text: widget.entry.value?.toString() ?? '');
  late final _weight = TextEditingController(text: widget.entry.weight == null ? '' : formatNum(widget.entry.weight!));
  final _weightFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _weightFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _value.dispose();
    _weight.dispose();
    _weightFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: Rule.thinSide)),
      child: _SetGrid(
        number: Text('${widget.number}', style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2)),
        value: AppTextField(
          controller: _value,
          hint: widget.isTime ? '45' : '10',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
          semanticLabel: 'Set ${widget.number} ${widget.isTime ? 'seconds' : 'reps'}',
          onChanged: (v) => widget.onChanged(e.withValue(int.tryParse(v))),
        ),
        weight: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: _weightFocus.hasFocus ? AppColors.accent : AppColors.divider),
          ),
          child: Row(
            children: [
              if (widget.isBodyweight)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('BW +', style: AppText.body.copyWith(fontSize: 13, fontWeight: FontWeight.w800, height: 1)),
                ),
              Expanded(
                child: TextField(
                  controller: _weight,
                  focusNode: _weightFocus,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    TextInputFormatter.withFunction((old, next) => _weightPattern.hasMatch(next.text) ? next : old),
                  ],
                  style: AppText.input,
                  expands: true,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    hintStyle: AppText.input.copyWith(color: AppColors.inkAlpha(0.35)),
                  ),
                  onChanged: (v) => widget.onChanged(e.withWeight(double.tryParse(v.replaceAll(',', '.')))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(widget.unit.name, style: AppText.muted13),
              ),
            ],
          ),
        ),
        action: AppIconButton(
          icon: LucideIcons.x,
          size: 16,
          tooltip: 'Remove set',
          onPressed: widget.onRemove,
        ),
      ),
    );
  }
}
