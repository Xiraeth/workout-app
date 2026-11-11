import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
Future<ExerciseSheetResult?> showExerciseSheet(BuildContext context, {Exercise? existing, required WeightUnit unit}) {
  // Created once: while the keyboard animates, the builder below runs every
  // frame, and passing the same widget lets Flutter skip rebuilding the sheet.
  final sheet = ExerciseSheet(existing: existing, unit: unit);
  return showModalBottomSheet<ExerciseSheetResult>(
    context: context,
    isScrollControlled: true,
    barrierColor: AppColors.scrim,
    // The sheet sits above the keyboard (so the focused field can scroll into
    // view) and takes 94% of the height that's left.
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(heightFactor: 0.94, child: sheet),
    ),
  );
}

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
    final isBw = _draft.equipment == Equipment.bodyweight;
    final isTime = _draft.measure == Measure.time;

    // Typing part of a name filters the list. An exact match (a picked or
    // edited exercise) shows the whole list with it selected; an unknown name
    // will be added on save.
    final library = ref.watch(exerciseLibraryProvider);
    final typed = nameKey(_draft.name);
    final exact = library.any((t) => t.key == typed);
    final matches = typed.isEmpty || exact ? library : library.where((t) => t.key.contains(typed)).toList();
    final isNew = typed.isNotEmpty && !exact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetHandle(),
        // Header: Cancel | title | Save
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 14, 10),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppButton(label: 'Cancel', variant: BtnVariant.ghost, height: 40, onPressed: () => Navigator.of(context).pop()),
                ),
              ),
              Text(_isEdit ? 'Edit exercise' : 'New exercise', style: AppText.title),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: 'Save',
                    variant: BtnVariant.primary,
                    height: 40,
                    radius: Radii.pill,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    onPressed: _canSave ? _save : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Space.side, 8, Space.side, 0),
            children: [
              // Name and quick picks
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Exercise'),
                    AppTextField(
                      controller: _name,
                      hint: 'e.g. Bench press',
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (v) => _set(_draft.copyWith(name: v)),
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Your exercises', trailing: 'Hold to remove'),
                    if (matches.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in matches)
                            AppChip(
                              label: t.name,
                              compact: true,
                              selected: t.key == typed,
                              onTap: () => _pick(t),
                              onLongPress: () => _forget(t),
                            ),
                        ],
                      ),
                    if (isNew)
                      Padding(
                        padding: EdgeInsets.only(top: matches.isEmpty ? 0 : 10),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.sparkles, size: 15, color: AppColors.accent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text('New exercise. Saving adds it to your exercises.',
                                  style: AppText.tiny.copyWith(color: AppColors.accentDark, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Type
              AppCard(
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
                    const SizedBox(height: 14),
                    const FieldLabel('Measured by'),
                    SegControl<Measure>(
                      options: Measure.values,
                      value: _draft.measure,
                      labelOf: (m) => m.label,
                      onChanged: (m) => _set(_draft.copyWith(measure: m)),
                    ),
                    const SizedBox(height: 14),
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
              const SizedBox(height: 14),

              // Sets
              AppCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 4, 4, 12),
                      child: Text(
                        isBw
                            ? 'BW = your bodyweight. Add a vest or belt load, or leave blank.'
                            : 'Total weight moved per set — bar plus plates, or per dumbbell.',
                        style: AppText.tiny,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: AppButton(label: 'Add set', icon: LucideIcons.plus, variant: BtnVariant.tonal, block: true, onPressed: _addSet),
                    ),
                  ],
                ),
              ),

              if (_isEdit) ...[
                const SizedBox(height: 14),
                AppButton(
                  label: 'Remove exercise from session',
                  icon: LucideIcons.trash2,
                  variant: BtnVariant.ghost,
                  foreground: AppColors.missed,
                  block: true,
                  onPressed: () => Navigator.of(context).pop(const ExerciseRemoved()),
                ),
              ],
              const _BottomSpace(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Space after the last item. With the keyboard open the sheet already ends
/// above it; otherwise keep clear of the navigation bar. Only this widget
/// depends on the keyboard height, so only it rebuilds while the keyboard moves.
class _BottomSpace extends StatelessWidget {
  const _BottomSpace();

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return SizedBox(height: keyboardOpen ? 28 : bottomGap(context, min: 28));
  }
}

/// Columns: badge | value | weight | remove.
class _SetGrid extends StatelessWidget {
  const _SetGrid({required this.number, required this.value, required this.weight, required this.action});

  final Widget number, value, weight, action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 30, child: number),
        const SizedBox(width: 10),
        Expanded(flex: 10, child: value),
        const SizedBox(width: 8),
        Expanded(flex: 14, child: weight),
        const SizedBox(width: 4),
        SizedBox(width: 36, child: action),
      ],
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppText.tiny.copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: AppColors.faint));
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: _SetGrid(
        number: NumberBadge(widget.number, filled: false),
        value: AppTextField(
          controller: _value,
          hint: widget.isTime ? '45' : '10',
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
          semanticLabel: 'Set ${widget.number} ${widget.isTime ? 'seconds' : 'reps'}',
          onChanged: (v) => widget.onChanged(e.withValue(int.tryParse(v))),
        ),
        weight: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(Radii.field),
            border: Border.all(color: _weightFocus.hasFocus ? AppColors.accent : Colors.transparent, width: 2),
          ),
          child: Row(
            children: [
              if (widget.isBodyweight)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('BW +', style: AppText.badge.copyWith(color: AppColors.accentDark)),
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
                    hintStyle: AppText.input.copyWith(color: AppColors.faint),
                  ),
                  onChanged: (v) => widget.onChanged(e.withWeight(double.tryParse(v.replaceAll(',', '.')))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(widget.unit.name, style: AppText.small),
              ),
            ],
          ),
        ),
        action: AppIconButton(
          icon: LucideIcons.x,
          size: 36,
          iconSize: 16,
          flat: true,
          iconColor: AppColors.muted,
          tooltip: 'Remove set',
          onPressed: widget.onRemove,
        ),
      ),
    );
  }
}
