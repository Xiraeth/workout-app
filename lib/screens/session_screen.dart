import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../utils/dates.dart';
import '../utils/format.dart';
import '../widgets/app_buttons.dart';
import '../widgets/common.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/exercise_sheet.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  /// The last version seen, so the screen keeps drawing while it animates out
  /// after the session has been deleted.
  Session? _last;
  bool _leaving = false;

  SessionsNotifier get _sessions => ref.read(sessionsProvider.notifier);

  void _update(Session Function(Session) fn) => _sessions.update(widget.sessionId, fn);

  /// Back: discard the session if it has no exercises and no body parts, and
  /// select its date in the week view.
  void _leave() {
    if (_leaving) return;
    _leaving = true;
    final current = _sessions.byId(widget.sessionId);
    Navigator.of(context).pop();
    if (current == null) return;
    ref.read(selectedDateProvider.notifier).select(current.date);
    if (current.isEmpty) _sessions.remove(current.id);
  }

  Future<void> _delete(Session s) async {
    final ok = await showDeleteSessionDialog(context, s);
    if (ok != true || !mounted || _leaving) return;
    _leaving = true;
    Navigator.of(context).pop();
    _sessions.remove(s.id);
  }

  Future<void> _pickDate(Session s) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: s.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) _update((x) => x.copyWith(date: picked));
  }

  Future<void> _editExercise(Exercise? existing) async {
    final result = await showExerciseSheet(context, existing: existing, unit: ref.read(settingsProvider).unit);
    if (result == null) return;
    if (result is ExerciseSaved) ref.read(exerciseLibraryProvider.notifier).remember(result.exercise);
    _update((s) => switch (result) {
          ExerciseSaved(:final exercise) => s.copyWith(
              exercises: existing == null
                  ? [...s.exercises, exercise]
                  : [for (final e in s.exercises) e.id == existing.id ? exercise : e],
            ),
          ExerciseRemoved() => s.copyWith(exercises: s.exercises.where((e) => e.id != existing?.id).toList()),
        });
  }

  @override
  Widget build(BuildContext context) {
    final found = ref.watch(sessionsProvider.select((list) {
      for (final s in list) {
        if (s.id == widget.sessionId) return s;
      }
      return null;
    }));
    if (found != null) _last = found;
    final s = _last;
    final unit = ref.watch(settingsProvider).unit;
    final today = dateOnly(ref.watch(clockProvider)());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Scaffold(
          body: s == null
              ? const SizedBox.shrink()
              : SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _topBar(s),
                      _header(s, today),
                      Expanded(child: _body(s, unit)),
                      BottomBar(
                        child: AppButton(
                          label: s.done
                              ? 'Completed · tap to reopen'
                              : s.date.isAfter(today)
                                  ? 'Mark complete early'
                                  : 'Mark session complete',
                          icon: LucideIcons500.check,
                          iconSize: 18,
                          variant: s.done ? BtnVariant.secondary : BtnVariant.primary,
                          block: true,
                          height: 48,
                          fontSize: 15,
                          onPressed: () => _update((x) => x.copyWith(done: !x.done)),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _topBar(Session s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          AppButton(
            label: 'Week',
            icon: LucideIcons.chevronLeft,
            iconSize: 18,
            variant: BtnVariant.ghost,
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
            onPressed: _leave,
          ),
          const Spacer(),
          AppIconButton(
            icon: LucideIcons.trash2,
            tooltip: 'Delete session',
            pressedBg: AppColors.accent100,
            pressedFg: AppColors.accent700,
            onPressed: () => _delete(s),
          ),
        ],
      ),
    );
  }

  Widget _header(Session s, DateTime today) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Space.side, 4, Space.side, 14),
      decoration: const BoxDecoration(border: Border(bottom: Rule.thickSide)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusTag(s.status(today)),
          const SizedBox(height: 8),
          Text(sessionTitle(s.date), style: AppText.h2),
        ],
      ),
    );
  }

  Widget _body(Session s, WeightUnit unit) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.side, 18, Space.side, 24),
      children: [
        // Date
        const FieldLabel('Date'),
        _DateField(date: s.date, onTap: () => _pickDate(s)),
        const SizedBox(height: 20),

        // Body parts
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: FieldLabel('Body parts', trailing: s.parts.isEmpty ? 'Optional · pick any' : '${s.parts.length} selected'),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final p in BodyPart.values)
              AppChip(
                label: p.label,
                selected: s.parts.contains(p),
                onTap: () => _update((x) => x.togglePart(p)),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Exercises
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(border: Border(bottom: Rule.thickSide)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text('Exercises', style: AppText.h4)),
              Text('${s.exercises.length} logged', style: AppText.muted12),
            ],
          ),
        ),
        for (final (i, e) in s.exercises.indexed) _ExerciseRow(index: i, exercise: e, unit: unit, onTap: () => _editExercise(e)),
        if (s.exercises.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(border: Border(bottom: Rule.thinSide)),
            child: Text('No exercises yet.', style: AppText.muted13),
          ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Add exercise',
          icon: LucideIcons500.plus,
          block: true,
          height: 44,
          onPressed: () => _editExercise(null),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Date, ${dateField(date)}',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: Border.all(color: AppColors.divider),
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: AppColors.inkAlpha(0.04),
          hoverColor: Colors.transparent,
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(child: Text(dateField(date), style: AppText.input)),
                  Icon(LucideIcons.calendar, size: 16, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.index, required this.exercise, required this.unit, required this.onTap});

  final int index;
  final Exercise exercise;
  final WeightUnit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RuledRow(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text((index + 1).toString().padLeft(2, '0'),
                style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2, color: AppColors.accent)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: AppText.exerciseName),
                const SizedBox(height: 3),
                Text(setSummary(exercise, unit), style: AppText.body.copyWith(fontSize: 14, height: 1.4)),
                const SizedBox(height: 3),
                Text(typeLine(exercise).toUpperCase(), style: AppText.caps(11, weight: FontWeight.w400, em: 0.06, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(LucideIcons.chevronRight, size: 16, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
