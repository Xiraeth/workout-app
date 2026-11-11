# Design system

A light, rounded, colourful look: soft white cards on a cool grey page, an indigo brand colour, and extra colours that carry meaning (status, categories). It replaced an earlier flat, square, black-and-indigo design that felt dated. The look takes cues from modern dashboards (AWS's rounded console, tinted summary tiles) rather than from any one product.

Everything lives in `lib/theme/tokens.dart` (values) and `lib/widgets/common.dart` / `app_buttons.dart` (components). Change values there, not in screens.

## Principles

- **Rounded everywhere.** Nothing is square: cards 20, tiles and buttons 16, inputs 14, sheets 28 (top corners), pills fully round.
- **Depth through soft shadows, not borders.** White cards float on the grey page with a wide, faint shadow. Borders are only for unselected chips.
- **Colour means something.** Indigo is the brand and the main action. Green = done, indigo = planned, coral = missed. Categories (body-part groups) get their own hue. Each hue has a solid, a darker text shade and a light tint, so it can be used as a fill, as text, or as a background.
- **Tints for information, gradients for actions.** Summary tiles and tags use light tints with coloured text. Primary buttons, the selected day and selected segments use an indigo gradient with a coloured glow.
- **Friendly type.** Plus Jakarta Sans, heavy (800) headings with slight negative tracking, medium (500) body text, small uppercase labels in a colour.
- **Gentle motion.** Tappables shrink slightly when pressed (`Pressable`, scale 0.92–0.98, 110 ms). Segmented controls slide their highlight (220 ms). No ripples.

## Colours

| Token | Hex | Use |
|---|---|---|
| bg | `#F4F5FA` | Page background |
| surface | `#FFFFFF` | Cards, sheets, chips |
| field | `#EEF0F6` | Inputs, segmented-control track |
| line | `#E3E6EF` | Hairlines, chip borders, sheet handle |
| ink | `#161A2B` | Main text |
| muted | `#6B7085` | Secondary text, labels |
| faint | `#9EA3B5` | Placeholders, chevrons, table headers |
| accent | `#4F46E5` | Indigo 600: brand, primary fills |
| accentLight | `#6366F1` | Gradient start |
| accentDark | `#4338CA` | Indigo text on light backgrounds |
| accentTint | `#EEF0FF` | Tonal buttons, indigo tints |
| scrim | ink @ 40% | Behind sheets and dialogs |

Hues (`Hue` in `tokens.dart`, solid / text / tint):

| Hue | Solid | Text | Tint | Used for |
|---|---|---|---|---|
| indigo | `#4F46E5` | `#4338CA` | `#EEF0FF` | Planned, full body, brand |
| green | `#16A34A` | `#15803D` | `#E7F8EE` | Done |
| coral | `#F04438` | `#B42318` | `#FEF0EF` | Missed, destructive |
| violet | `#7C3AED` | `#6D28D9` | `#F3EEFF` | Push (chest, shoulders, triceps) |
| sky | `#0284C7` | `#0369A1` | `#E6F4FC` | Pull (back, biceps, forearms) |
| pink | `#DB2777` | `#BE185D` | `#FDEEF5` | Core |
| orange | `#EA580C` | `#C2410C` | `#FFF1E8` | Legs, "sets done" tile |
| amber | `#D97706` | `#B45309` | `#FEF5E7` | Empty/rest state |

## Type (Plus Jakarta Sans)

| Style | Size / weight | Notes |
|---|---|---|
| h1 | 32 / 800 | -0.02em, page title (month) |
| h2 | 28 / 800 | -0.02em, detail title (date), big numbers |
| h3 | 20 / 800 | Sheet and dialog titles |
| h4 | 18 / 700 | Section titles |
| title | 17 / 700 | Card titles |
| body | 15 / 500 | |
| small | 13 / 500 | Muted secondary lines |
| tiny | 12 / 500 | Hints |
| label | 13 / 600 | Field labels, muted |
| button | 15 / 700 | |
| input | 16 / 600 | |
| overline | 11 / 700 | +0.08em, uppercase, accent ("WEEK 46 · 2026") |
| badge | 12 / 700 | Tags, pills, badges |

## Spacing, radii, shadows

- Spacing scale 4 / 8 / 12 / 16 / 20 / 24 / 32; screen side padding 20; cards padded 16; gaps between cards 10–14; sections 28 apart.
- Radii: card 20, tile 16, button 16, field 14, sheet 28, pill 999.
- `Shadows.card`: `0 8 24` ink @ 6% + `0 1 3` ink @ 4%. `Shadows.small`: `0 3 10` ink @ 8% (round icon buttons). `Shadows.glow(c)`: `0 8 20` c @ 35% under gradients.
- Gradients: top-left to bottom-right, lighter to base (`accentGradient` = `#6366F1` → `#4F46E5`).

## Components

- **AppCard**: white, radius 20, card shadow; tappable cards press to 0.98.
- **AppButton** variants: `primary` (indigo gradient + glow, white text), `tonal` (accent tint, indigo text), `neutral` (white + small shadow), `ghost` (text only), `danger` (solid coral + glow), `success` (green tint). Heights 40 (header), 44–50 (in content), 54 (screen's main action). Disabled = 45% opacity.
- **AppIconButton**: 40px circle, white with small shadow, or tinted (delete = coral tint + coral icon), or flat.
- **SegControl**: pill track in `field` grey with a sliding indigo-gradient pill; labels centred, white when selected.
- **AppChip**: pill; unselected = white with hairline border and a small coloured dot; selected = solid hue fill, white text, check icon, coloured glow.
- **StatusTag**: tinted pill with a coloured dot (Done / Planned / Missed).
- **TintPill**: small tinted uppercase pill ("TODAY").
- **NumberBadge**: gradient circle with a white number (exercise index), or tint circle with coloured number (set index).
- **IconTile**: rounded square (radius ~32% of size) with a hue gradient, white icon and coloured glow; identifies a card's category.
- **Summary tiles**: tinted rounded tiles with an icon + label in the text shade and a big number in the solid shade.
- **Inputs**: `field` grey fill, no border, 2px indigo ring when focused, 48px tall.
- **Bottom sheets**: `bg` colour, 28 top radius, grab handle, header row (ghost Cancel · title · pill primary Save); content in cards.
- **BottomBar**: the screen's main action floats over content on a fade from transparent to `bg`, padded above the system navigation bar.

Icons are Lucide (`lucide_icons_flutter`), 16–18px in controls, ink or a hue colour.
