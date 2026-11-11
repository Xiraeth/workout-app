# Workout Log

A Flutter app for scheduling and tracking strength workouts. You plan or log sessions on dates; each session has optional body parts and a list of exercises, and each exercise has a type (bodyweight/free weights, reps/time, dynamic/isometric) and sets. Data stays on the device.

The original design reference is in `Workout Log Mobile Prototype-vip/design_handoff_workout_log/` (README with screen specs and behaviour, plus the HTML prototype). The behaviour still follows it; the look has since been redesigned (rounded, more colour).

## Commands

```sh
flutter run            # run on a connected phone (USB debugging on) or emulator
flutter test           # unit + widget tests
flutter analyze
flutter build apk      # release APK in build/app/outputs/flutter-apk/
```

Debug builds seed sample sessions on first launch; release builds start empty.

## Layout

- `lib/theme/`: design tokens (`tokens.dart`: colours, status and body-part hues, radii, shadows, text styles) and `ThemeData` (`app_theme.dart`). Light, rounded look with an indigo brand colour; the font is Plus Jakarta Sans, bundled in `assets/fonts/` (change `AppText.family` and `pubspec.yaml` to try another).
- `lib/models/`: `Session`, `Exercise`, `SetEntry`, enums, settings. Immutable, with JSON.
- `lib/data/`: `SessionRepository` interface with a JSON implementation (`sessions.json` = `{"version": 1, "sessions": [...]}`, atomic writes, corrupt files moved to `.bad`), settings repository, seed data.
- `lib/state/providers.dart`: Riverpod notifiers for sessions, the selected date and settings. Every change is saved.
- `lib/screens/`: Week (home) and Session detail.
- `lib/widgets/`: exercise sheet, settings sheet, confirm dialog, week strip, session cards and week summary, buttons (`Pressable` gives the press animation), segmented controls, chips, badges.
- `lib/utils/`: dates (ISO week, week start) and formatting (set summary, labels).

## Storage and a future move to sqlite

All storage goes through `SessionRepository`. To move to sqlite (e.g. drift), add an implementation of that interface and, on first launch, import `sessions.json` once. Ids are stable uuids and numbers are typed (`int?` reps/seconds, `double?` weight), so they map straight onto tables.
