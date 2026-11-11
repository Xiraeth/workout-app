# Workout Log

A Flutter app for scheduling and tracking strength workouts. You plan or log sessions on dates; each session has optional body parts and a list of exercises, and each exercise has a type (bodyweight/free weights, reps/time, dynamic/isometric) and sets. Data stays on the device.

The design reference is in `Workout Log Mobile Prototype-vip/design_handoff_workout_log/` (README with tokens and screen specs, plus the HTML prototype).

## Commands

```sh
flutter run            # run on a connected phone (USB debugging on) or emulator
flutter test           # unit + widget tests
flutter analyze
flutter build apk      # release APK in build/app/outputs/flutter-apk/
```

Debug builds seed sample sessions on first launch; release builds start empty.

## Layout

- `lib/theme/`: design tokens (`tokens.dart`) and `ThemeData` (`app_theme.dart`): radius 0, no shadows, no ripples, Archivo (bundled in `assets/fonts/`).
- `lib/models/`: `Session`, `Exercise`, `SetEntry`, enums, settings. Immutable, with JSON.
- `lib/data/`: `SessionRepository` interface with a JSON implementation (`sessions.json` = `{"version": 1, "sessions": [...]}`, atomic writes, corrupt files moved to `.bad`), settings repository, seed data.
- `lib/state/providers.dart`: Riverpod notifiers for sessions, the selected date and settings. Every change is saved.
- `lib/screens/`: Week (home) and Session detail.
- `lib/widgets/`: exercise sheet, settings sheet, delete dialog, week strip, cards, buttons, segmented controls, chips.
- `lib/utils/`: dates (ISO week, week start) and formatting (set summary, labels).

## Storage and a future move to sqlite

All storage goes through `SessionRepository`. To move to sqlite (e.g. drift), add an implementation of that interface and, on first launch, import `sessions.json` once. Ids are stable uuids and numbers are typed (`int?` reps/seconds, `double?` weight), so they map straight onto tables.
