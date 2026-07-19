# Design System

## Principles

The interface is minimal, calm, readable and accessible. It uses Material 3,
generous whitespace, moderate rounded corners, clear touch targets and no
gamification, public streaks, score/reward indicators or pressure language.

## Tokens

| Token | Value | Intended use |
| --- | --- | --- |
| Warm Ivory | `#F7F4EC` | Light scaffold background |
| Deep Forest | `#123F35` | Brand seed and prominent actions |
| Sage | `#A8BFAF` | Supporting accent |
| Muted Gold | `#C6A15B` | Sparse non-body-text accent only |
| Charcoal | `#17211D` | Dark text anchor |
| Dark Background | `#0D1714` | Dark scaffold background |

The shared package implements light/dark `ThemeData`, navigation theming,
consistent section cards and a non-judgemental empty state. The Android shell
uses an original abstract-path vector mark; browser/store raster assets remain
an explicit release-asset task rather than shipping Flutter defaults. It does
not bundle a font; any future font must have recorded rights and support Malay,
English and Arabic correctly.

## Accessibility

- Semantic headings and labelled navigation are present in the initial shells.
- Theme, text scale (90–150%) and reduced-motion controls supplement rather
  than override inherited OS accessibility settings; preference persistence is
  a later task.
- Layouts use responsive constraints and admin navigation switches between a
  navigation rail and drawer.
- Information may not be conveyed by colour alone; future content screens must
  preserve RTL, screen-reader, keyboard and large-text support.
