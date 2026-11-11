# Handoff: Workout Log (mobile app)

## Overview
A mobile app for scheduling and tracking strength workouts. You plan or log **sessions** on dates. Each session has optional **body parts** (pick several) and a list of **exercises**. Each exercise has a type and a list of **sets**:
- **Type:** Bodyweight / Free weights · Reps / Time · Dynamic / Isometric
- **Each set:** the reps or seconds, plus a weight. For bodyweight exercises the weight means "BW + added load".

**Target stack: Flutter + Dart** (iOS and Android). No backend; data is stored only on the device.

## About the design files
`Workout Log.dc.html` is a **design reference built in HTML**. It's a working prototype that shows the intended look and behaviour; it is not code to port line by line. Recreate it in Flutter using normal Flutter patterns. Open the file in a browser and click through it: the logic lives in the `<script data-dc-script>` class (`renderVals()` and its helpers), and it's the clearest spec for the behaviour.

## Fidelity
**High-fidelity.** Colours, type, spacing, borders and copy are final. Match them closely.

The visual language is **flat and Swiss-modernist**:
- No rounded corners anywhere (the radius is 0). Use `BorderRadius.zero` and turn off Material's default rounding.
- Strong 2px dividers between major sections and 1px dividers between rows.
- Everything is left-aligned, **including labels inside full-width buttons**.
- No shadows inside the app. Ink on a light grey background, with one accent colour.
- No ripple splash. Use flat colour changes for hover and press instead (`splashFactory: NoSplash.splashFactory`).

---

## Design tokens

### Colours
| Token | Hex | Use |
|---|---|---|
| bg | `#F3F2F2` | Screen background |
| surface | `#EAE9E9` | Cards, inputs |
| text (ink) | `#201E1D` | All body text, selected day fill |
| divider | `#201E1D` @ 40% opacity (`#66201E1D`) | All rules and borders |
| textMuted | `#201E1D` @ 55% | Secondary text |
| labelText | `#201E1D` @ 70% | Field labels |
| **accent** | `#4B3BC4` | Primary buttons, selected chips/segments, today's date, exercise index, day dots |
| accent-100 | `#F2F0FD` | Tinted fills (Done tag bg) |
| accent-200 | `#E1DDFA` | |
| accent-300 | `#C7C0F4` | |
| accent-400 | `#9D92EA` | |
| accent-500 | `#6A5BDC` | |
| accent-600 | `#3E2FA8` | Primary button **hover/pressed** |
| accent-700 | `#30238A` | Accent text at small sizes (kickers, "Today", destructive ghost), primary button **active** |
| accent-800 | `#231A66` | Text on accent-100 tags |
| accent-900 | `#171142` | |
| neutral-100 | `#F8F4F4` | "Missed" tag bg |
| neutral-300 | `#D7D3D3` | Card hover/pressed bg |
| neutral-800 | `#444141` | "Missed" tag text |
| neutral-900 | `#2D2B2B` | Modal scrim base (50% opacity) |

Small text in the accent colour must use **accent-700** to keep enough contrast. Use the base accent only for fills, icons and text 15px or larger.

### Typography
One family: **Archivo** (Google Fonts; weights 400, 600, 800). In Flutter use `google_fonts` or bundle the font files.
| Role | Size | Weight | Line-height | Letter-spacing |
|---|---|---|---|---|
| H1 (month) | 42 | 800 | 1.12 | -0.015em |
| H2 (session date) | 32 | 800 | 1.12 | -0.015em |
| H4 (section) | 20 | 800 | 1.12 | -0.015em |
| H6 / overline | 13 | 800 | 1.12 | 0.08em, UPPERCASE |
| Card title | 20 | 800 | 1.2 | — |
| Exercise name | 16 | 800 | 1.2 | — |
| Body | 15 | 400 | 1.55 | — |
| Button | 14–15 | 800 | 1.2 | — |
| Input text | 16 | 600 | — | — |
| Label | 12 | 400 | — | — |
| Kicker / tag-ish caps | 10–12 | 600 | — | 0.06–0.1em, UPPERCASE |
| Tag | 11 | 400 | — | 0.02em |

### Spacing
The scale is 4 / 8 / 12 / 16 / 24 / 32. The screen's side padding is **20**.

### Other
- Radius: **0** everywhere.
- Shadows: none in the app UI. The prototype's phone bezel is only for presentation; don't build it.
- Minimum tap target: 44px (inputs and the bottom buttons are 44–48px tall).

---

## Data model
```dart
enum Equipment { bodyweight, freeWeights }
enum Measure { reps, time }        // time is stored in seconds
enum Motion { dynamic, isometric }

class SetEntry { String value; String weight; } // value = reps or seconds; weight = kg/lb (added load if bodyweight); '' = empty

class Exercise {
  String id; String name;
  Equipment equipment; Measure measure; Motion motion;
  List<SetEntry> sets; // at least 1
}

class Session {
  String id; DateTime date; // date only, no time
  List<BodyPart> parts;     // optional, multi-select, keep in canonical order
  bool done;
  List<Exercise> exercises;
}
```
Body parts, in canonical order: Chest, Back, Shoulders, Biceps, Triceps, Forearms, Core, Glutes, Quads, Hamstrings, Calves, Full body.

**Derived status:** `done` → **Done**. Otherwise, a date before today → **Missed**, and today or later → **Planned**.

**Persistence:** store data locally, e.g. `hive`, `isar`, `drift`/sqlite, or JSON in `shared_preferences`. Save on every change.

**Settings** (Tweaks in the prototype): units `kg | lb` (labels only, no conversion) and week start `Monday | Sunday`. Default: kg, Monday.

---

## Screens

### 1. Week (home)
**Purpose:** browse a week, pick a day, see that day's sessions and what's coming up, and create a session.

**Layout** (column, full height):
1. **Header** (padding 8/20/14, 2px bottom rule). On the left: an overline `WEEK {isoWeek} · {year}` (11px, 600, uppercase, 0.1em spacing, accent-700) above an H1 with the month name ("November") of the selected date. On the right: two 36×36 secondary icon buttons (chevron-left / chevron-right) with a 4px gap. They move the selection by ±7 days.
2. **Week strip:** a 7-column equal grid with a 2px bottom rule and a 1px right rule on each cell. Each cell is a button with padding 10/0/12/8, left-aligned, in a column with a 3px gap:
   - Two-letter day ("Mo"), 11px, 600, uppercase
   - Day number, 22px, 800
   - An 8×8 **square** marker with a 1.5px border. It's invisible if the day has no session, accent-outlined if it only has planned sessions, and accent-filled if any session is done.
   - **Selected day:** ink fill (`#201E1D`) with bg-coloured text. **Today (not selected):** the number and letters are in the accent colour.
3. **Scrolling body** (padding 20):
   - A row with an H4 date ("Wednesday 11 November") and, on the right, "TODAY" / "TOMORROW" / "YESTERDAY" (12px, 600, uppercase, accent-700) when it applies.
   - **Session cards** for the selected day, 8px apart. Card: surface bg, padding 14, no border, column with an 8px gap; pressed/hover bg neutral-300.
     - Row: a kicker on the left, `{n} exercises · {m} sets` (10px caps, 0.1em, accent-700), and a **status tag** on the right.
     - Title: the body parts joined with " · ", or "Untitled session" (20px, 800).
     - Body: the exercise names joined with ", ", or "No exercises yet" (13px, 80% opacity).
   - **Empty state** (if there are no sessions): a block with 2px rules above and below and padding 18/0. "Nothing scheduled" (17px, 800), then "Plan a session for this day, or log one you already did." (13px, muted).
   - **"COMING UP"** (H6, 28px top margin, 2px rule under it): up to 4 sessions that are not done, dated today or later, and not on the selected day, sorted by date. Each row is a button: grid `64px | 1fr | auto`, gap 12, padding 12/0, 1px bottom rule.
     - Column 1: the short date ("Fri 13"), 12px, 600, caps.
     - Column 2: the title (15px, 800, single line, ellipsis) and the meta line (12px, muted).
     - Column 3: chevron-right.
4. **Bottom bar** (padding 12/20/24, 2px top rule): a full-width **primary** button, 48px tall, label left-aligned: `[+] New session · {Wed 11}`. It creates an empty session on the selected date and opens it.

**Status tags** (padding 3/10, 11px, radius 0):
- Done: bg accent-100, text accent-800
- Planned: 1px accent border, accent text, transparent bg
- Missed: bg neutral-100, text neutral-800

### 2. Session detail
**Purpose:** edit one session's date, body parts and exercises, and mark it complete.

**Layout:**
1. **Top bar** (padding 4/12). On the left, a ghost button with chevron-left + "Week" in the accent colour; it goes back. On the right, a 36×36 trash icon button (hover: accent-100 bg, accent-700 icon) that opens the delete dialog.
2. **Header** (padding 4/20/14, 2px bottom rule): a status tag, then an H2 with the date ("Wednesday 11 Nov"), 8px below.
3. **Scrolling body** (padding 18/20/24, column with a 20px gap):
   - **Date field:** label "Date", then a 44px input (surface bg, 1px divider border, focus border accent) that opens the native date picker. Changing it moves the session.
   - **Body parts:** a label row with "Body parts" on the left and, on the right, "Optional · pick any" or "{n} selected" (12px muted). Below it, wrapping chips with a 6px gap. Chip: padding 8/12, min-height 36, 13px, 600, 1px border.
     - Off: transparent bg, divider border, ink text.
     - On: accent bg, accent border, bg-coloured text.
     - Tapping toggles. Keep the selection in canonical order.
   - **Exercises:** a header row with an H4 "Exercises" and "{n} logged" (12px muted) on the right, plus a 2px rule under it. Each exercise row is a button: grid `32px | 1fr | auto`, gap 10, padding 14/0, 1px bottom rule.
     - Index "01", "02"… (15px, 800, accent).
     - Stacked with a 3px gap: the name (16px, 800), the **set summary** (14px), and the type line (11px, caps, 0.06em, muted), e.g. `FREE WEIGHTS · REPS · DYNAMIC` or `BODYWEIGHT · TIMED · ISOMETRIC`.
     - Chevron-right. Tapping opens the exercise sheet in edit mode.
   - If there are no exercises: "No exercises yet." (13px muted, padding 14/0, 1px bottom rule).
   - **Add exercise:** a secondary full-width button, 44px, left-aligned `[+] Add exercise`, 12px top margin. Opens the sheet in create mode.
4. **Bottom bar** (2px top rule, padding 12/20/24): a full-width 48px toggle button with a check icon.
   - Not done: **primary**. The label is "Mark session complete", or "Mark complete early" if the date is in the future.
   - Done: **secondary** (1px divider border, transparent). Label: "Completed · tap to reopen".

**Set summary format:**
- Only sets with a non-empty value count. If there are none, show "No sets logged".
- Values: if they're all equal, `{count} × {value}`; otherwise the values joined with " / ".
- Times show as `45s` under 60 seconds, otherwise `m:ss` (`1:00`).
- Weight:
  - Bodyweight: `BW + {w} {unit}`, or just "Bodyweight" if nothing was added.
  - Free weights: `{w} {unit}`, or "No load".
  - If the set weights differ, show a range: `40–50 kg`.
- The two halves are joined with two spaces either side of a middle dot ("  ·  "). Examples: `3 × 8  ·  60 kg`, `10 / 8 / 6  ·  40–50 kg`, `2 × 1:00  ·  Bodyweight`.

**Back behaviour:** if the session has no exercises **and** no body parts, delete it automatically (so tapping "New session" and backing out leaves nothing behind). Going back sets the week view's selected date to the session's date.

**Delete dialog:** modal over a scrim (neutral-900 @ 50%). Dialog: surface bg, padding 16, gap 12, radius 0, max width 440. Contents:
- Title "Delete this session?" (20px, 800).
- Body "{date} and its {n} exercises will be removed." (14px, 85% opacity).
- Right-aligned actions: secondary "Keep" and primary "Delete". Delete goes back to the week view.

### 3. Exercise sheet (create / edit)
A modal bottom sheet covering **94%** of the screen height over the scrim. bg colour, a 2px ink top border, radius 0. Use `showModalBottomSheet(isScrollControlled: true, shape: RoundedRectangleBorder())`.

1. **Header** (3-column grid, padding 10/12, 2px bottom rule):
   - Ghost "Cancel" on the left; it discards changes.
   - Title in the centre: "New exercise" or "Edit exercise" (15px, 800).
   - Primary "Save" on the right. It's **disabled (45% opacity)** until the name is not empty after trimming.
2. **Scrolling body** (padding 18/20/28, column with a 20px gap):
   - **Name field:** label "Exercise", a 44px input, 16px 600 text, placeholder "e.g. Bench press".
   - **Quick pick:** label "Quick pick", then wrapping chips (6px gap, padding 6/10, 12px, 1px divider border). The chip whose name matches the current name shows inverted (ink bg, bg-coloured text). Tapping a chip sets the name **and** the type:
     - Push-up — bodyweight / reps / dynamic
     - Pull-up — bodyweight / reps / dynamic
     - Plank — bodyweight / time / isometric
     - Wall sit — bodyweight / time / isometric
     - Dip — bodyweight / reps / dynamic
     - Bench press — free weights / reps / dynamic
     - Back squat — free weights / reps / dynamic
     - Deadlift — free weights / reps / dynamic
     - Dumbbell curl — free weights / reps / dynamic
     - Farmer hold — free weights / time / isometric
   - **Type** (2px top rule, padding-top 16, column with a 12px gap): three labelled **segmented controls**, each full width with two equal segments, min-height 40, a 1px divider border, and a 1px divider between the segments. The selected segment has an accent fill and bg-coloured text; labels are left-aligned, 13px.
     - "Equipment": Bodyweight | Free weights
     - "Measured by": Reps | Time
     - "Movement": Dynamic | Isometric. **Choosing Isometric also sets Measured by to Time.** The user can switch it back.
   - **Sets table:**
     - Header row: grid `28px | 1fr | 1.2fr | 36px`, gap 8, 11px caps, 0.08em, 60% ink, 2px bottom rule. Columns: `SET`, `REPS` or `TIME (SEC)`, `LOAD` (bodyweight) or `WEIGHT` (free weights), and an empty column.
     - Rows: the same grid, padding 8/0, 1px bottom rule.
       - Set number (15px, 800).
       - Numeric input, 44px tall, 16px 600. Placeholder "10" for reps, "45" for time.
       - A 44px weight box with surface bg and a 1px divider border. It holds a "BW +" prefix (13px, 800; bodyweight only), a numeric input with placeholder "0" (step 0.5), and the unit suffix ("kg") in muted 13px.
       - A 36×36 remove (X) icon button. It's disabled when only one set remains.
     - Helper text (12px muted):
       - Bodyweight: "BW = your bodyweight. Add a vest or belt load, or leave blank."
       - Free weights: "Total weight moved per set — bar plus plates, or per dumbbell."
     - "Add set": a secondary full-width 44px button with `[+] Add set`. It **duplicates the last set's values** (empty if there are none).
   - **Edit mode only:** a ghost button in accent-700, "Remove exercise from session". It deletes the exercise and closes the sheet.
3. New exercise defaults: name '', Bodyweight / Reps / Dynamic, one empty set.
4. Saving appends a new exercise to the end of the list or replaces the one being edited, then closes the sheet.

---

## Interaction states (all controls)
| Control | Hover / pressed | Active (deeper press) |
|---|---|---|
| Primary button | accent-600 | accent-700 |
| Secondary / icon button | ink @ 7% overlay | ink @ 14% |
| Ghost button | accent @ 10% overlay | accent @ 18% |
| List rows | ink @ 4% overlay | |
| Cards | neutral-300 | |

- Inputs: border ink @ 45% on hover, accent when focused.
- Keyboard focus ring: a 2px accent outline offset by 2px.
- Disabled: 45% opacity.
- No ripples and no rounding.
- Transitions: none are specified in the prototype. Use the platform defaults for page push/pop and the bottom sheet, and keep the rest instant.

## Navigation / state
- Routes: `WeekScreen` → `SessionScreen(sessionId)`. The exercise sheet and the delete dialog are modals.
- App state: `sessions`, `selectedDate` (defaults to today), and settings. Use Riverpod or Provider, or whatever you prefer.
- Draft state: while the sheet is open, edit a **deep copy** of the exercise. Only Save writes it back.

## Icons
Lucide icons are used: chevron-left, chevron-right, plus, trash-2, x, check. In Flutter use the `lucide_icons` package. Use 2px strokes with square caps, 16–18px. Plus and check are 2.5px in buttons.

## Sample data (for first launch / dev)
- 3 days ago, **Done**: Chest · Triceps · Shoulders
  - Bench press 10@40, 8@45, 6@50
  - Push-up 15, 12
  - Dumbbell shoulder press 10@14, 10@14, 8@16
- Yesterday, **Done**: Core
  - Plank 60s, 45s
  - Hollow hold 3×30s
  - Hanging leg raise 12, 10
- Today, **Planned**: Quads · Glutes · Hamstrings
  - Back squat 3×8@60
  - Wall sit 60s, BW+10
- In 2 days, **Planned**: Back · Biceps
  - Pull-up 8, 6, 6
  - Dumbbell curl 12@10, 10@12
- In 5 days, **Planned**: Full body, no exercises

## Files
- `Workout Log.dc.html`: the interactive prototype. It's the source of truth for behaviour; open it in a browser together with `support.js` and `_ds/`. Layout is in the template markup; logic is in the `class Component` script (`renderVals`, `summ`, `card`, `seed`).
- `_ds/…/styles.css`: the design system's base tokens and component classes (`.btn`, `.input`, `.seg`, `.tag`, `.card`, `.dialog`). **Note:** the prototype overrides the accent ramp with the indigo values listed above. Those values win over the red in `styles.css`.

## Suggested Flutter structure
```
lib/
  theme/app_theme.dart     // ThemeData: colours above, Archivo, radius 0, NoSplash, button/input themes
  models/                  // Session, Exercise, SetEntry, enums (+ JSON)
  data/session_repository.dart
  state/                   // sessions + selectedDate + settings
  screens/week_screen.dart
  screens/session_screen.dart
  widgets/exercise_sheet.dart, week_strip.dart, session_card.dart, status_tag.dart, seg_control.dart, rule.dart
  utils/format.dart        // set summary, time format, ISO week
```
