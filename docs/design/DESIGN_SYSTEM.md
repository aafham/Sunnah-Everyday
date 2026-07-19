# Design System

The executable layout, component, state and accessibility contract is in
[UX_SPECIFICATION.md](UX_SPECIFICATION.md). It records the current shell only;
it does not authorize a content, authentication or publication path.

## Principles

The interface is minimal, calm, readable and accessible. It uses Material 3,
generous whitespace, moderate rounded corners, clear touch targets and no
gamification, public streaks, score/reward indicators or pressure language.
Daily UI is a status surface, not a content fallback: before a verified public
bundle exists it may show only an unavailable state, never draft, staging,
unreviewed or generated religious material.

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
  than override inherited OS accessibility settings. The first-launch state,
  BM/English choice and these UI controls persist only in an allowlisted
  on-device preference store; it never stores content, sources, reviews,
  reflections or credentials.
- Layouts use responsive constraints and admin navigation switches between a
  navigation rail and drawer at the documented 960 logical-pixel breakpoint.
- Mobile shell surfaces use a 560 logical-pixel readable-content cap on larger
  displays while retaining their four-item bottom navigation.
- Information may not be conveyed by colour alone; future content screens must
  preserve RTL, screen-reader, keyboard and large-text support. Full RTL and
  broader localisation accessibility coverage remain PDX-03 work.
