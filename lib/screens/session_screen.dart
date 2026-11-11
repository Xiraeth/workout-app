import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
import '../widgets/session_card.dart';

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
    final picked = await showDatePicker(context: context, initialDate: s.date, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) _update((x) => x.copyWith(date: picked));
  }

  Future<void> _editExercise(Exercise? existing) async {
    final result = await showExerciseSheet(context, existing: existing, unit: ref.read(settingsProvider).unit);
    if (result == null) return;
    if (result is ExerciseSaved) ref.read(exerciseLibraryProvider.notifier).remember(result.exercise);
    _update(
      (s) => switch (result) {
        ExerciseSaved(:final exercise) => s.copyWith(
          exercises: existing == null ? [...s.exercises, exercise] : [for (final e in s.exercises) e.id == existing.id ? exercise : e],
        ),
        ExerciseRemoved() => s.copyWith(exercises: s.exercises.where((e) => e.id != existing?.id).toList()),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final found = ref.watch(
      sessionsProvider.select((list) {
        for (final s in list) {
          if (s.id == widget.sessionId) return s;
        }
        return null;
      }),
    );
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
                    children: [
                      Padding(padding: const EdgeInsets.fromLTRB(Space.side, 8, Space.side, 8), child: _topBar(s)),
                      Expanded(
                        child: Stack(
                          children: [
                            ListView(
                              padding: const EdgeInsets.fromLTRB(Space.side, 8, Space.side, 120),
                              children: [
                                _header(s, today),
                                const SizedBox(height: 20),
                                _details(s),
                                const SizedBox(height: 28),
                                ..._exercises(s, unit),
                              ],
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: BottomBar(
                                child: AppButton(
                                  label: s.done
                                      ? 'Completed · tap to reopen'
                                      : s.date.isAfter(today)
                                      ? 'Mark complete early'
                                      : 'Mark session complete',
                                  icon: s.done ? LucideIcons.circleCheck : LucideIcons.check,
                                  variant: s.done ? BtnVariant.success : BtnVariant.primary,
                                  block: true,
                                  height: 54,
                                  fontSize: 16,
                                  onPressed: () => _update((x) => x.copyWith(done: !x.done)),
                                ),
                              ),
                            ),
                          ],
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
    return Row(
      children: [
        AppButton(
          label: 'Week',
          icon: LucideIcons.chevronLeft,
          height: 40,
          radius: Radii.pill,
          padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
          onPressed: _leave,
        ),
        const Spacer(),
        AppIconButton(
          icon: LucideIcons.trash2,
          tooltip: 'Delete session',
          tint: AppColors.missedTint,
          iconColor: AppColors.missed,
          onPressed: () => _delete(s),
        ),
      ],
    );
  }

  Widget _header(Session s, DateTime today) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusTag(s.status(today)),
              const SizedBox(height: 10),
              Text(sessionTitle(s.date), style: AppText.h2),
              const SizedBox(height: 4),
              Text(sessionMeta(s), style: AppText.small),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconTile(icon: s.done ? LucideIcons.check : LucideIcons.dumbbell, hue: s.done ? Hue.green : hueForSession(s), size: 56),
      ],
    );
  }

  Widget _details(Session s) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FieldLabel('Date'),
          _DateField(date: s.date, onTap: () => _pickDate(s)),
          const SizedBox(height: 18),
          FieldLabel('Body parts', trailing: s.parts.isEmpty ? 'Optional · pick any' : '${s.parts.length} selected'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in BodyPart.values)
                AppChip(label: p.label, hue: hueForPart(p), selected: s.parts.contains(p), onTap: () => _update((x) => x.togglePart(p))),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _exercises(Session s, WeightUnit unit) => [
    SectionTitle('Exercises', trailing: '${s.exercises.length} logged'),
    for (final (i, e) in s.exercises.indexed) ...[
      if (i > 0) const SizedBox(height: 10),
      _ExerciseCard(index: i, exercise: e, unit: unit, onTap: () => _editExercise(e)),
    ],
    if (s.exercises.isEmpty)
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Text('No exercises yet.', style: AppText.small),
      ),
    const SizedBox(height: 12),
    AppButton(
      label: 'Add exercise',
      icon: LucideIcons.plus,
      variant: BtnVariant.tonal,
      block: true,
      height: 50,
      onPressed: () => _editExercise(null),
    ),
  ];
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(Radii.field);
    return Semantics(
      button: true,
      label: 'Date, ${dateField(date)}',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.99,
        borderRadius: r,
        decoration: BoxDecoration(color: AppColors.field, borderRadius: r),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              const Icon(LucideIcons.calendarDays, size: 18, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(child: Text(dateField(date), style: AppText.input)),
              Text('Change', style: AppText.label.copyWith(color: AppColors.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.index, required this.exercise, required this.unit, required this.onTap});

  final int index;
  final Exercise exercise;
  final WeightUnit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumberBadge(index + 1),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: AppText.title.copyWith(fontSize: 16)),
                const SizedBox(height: 3),
                Text(
                  setSummary(exercise, unit),
                  style: AppText.body.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accentDark),
                ),
                const SizedBox(height: 4),
                Text(
                  typeLine(exercise).toUpperCase(),
                  style: AppText.tiny.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(LucideIcons.chevronRight, size: 18, color: AppColors.faint),
          ),
        ],
      ),
    );
  }
}
