# Mobile and Admin UX Specification

## Scope and boundary

This is the executable UI contract for the current Flutter shells. It defines
layout, interaction, accessibility and safe-state behaviour only. It does not
define religious content, source rights, review decisions, authentication,
publication, notifications or release eligibility.

The public mobile shell must continue to fail closed: before an authoritative,
verified public bundle exists, the Daily surface can expose only its unavailable
state. It must not read or render draft CSV, staging directories, approved
directories, network content, identifiers, titles, sources, evidence, grades
or body text.

## Tokens and shared primitives

The implementation source of truth is `packages/design_system`.

| Contract | Value / behaviour | Implementation |
| --- | --- | --- |
| Warm Ivory | `#F7F4EC`, light scaffold | `SunnahColors.warmIvory` |
| Deep Forest | `#123F35`, brand seed | `SunnahColors.deepForest` |
| Sage | `#A8BFAF`, supporting accent | `SunnahColors.sage` |
| Muted Gold | `#C6A15B`, non-body-text accent only | `SunnahColors.mutedGold` |
| Charcoal | `#17211D`, dark text anchor | `SunnahColors.charcoal` |
| Dark Background | `#0D1714`, dark scaffold | `SunnahColors.darkBackground` |
| Theme | Material 3; transparent, non-elevated app bar; light/dark themes | `sunnahTheme` |
| Control radius | 16 logical pixels for input and floating snackbar shapes | `SunnahLayout.controlRadius` |
| Mobile navigation | 72 logical pixels high | `SunnahLayout.navigationBarHeight` |
| Mobile readable width | 560 logical pixels maximum for shell content | `SunnahContentFrame` |
| Section rhythm | 20 logical-pixel card padding | `SunnahLayout.sectionCardPadding` |
| Empty-state rhythm | 32 logical-pixel padding | `SunnahLayout.emptyStatePadding` |
| Admin content width | 1040 logical pixels maximum | `SunnahLayout.adminContentMaxWidth` |

`SunnahContentFrame` centers a fixed or scrollable mobile surface within the
readable width. `SunnahSectionCard` provides an optional uppercase eyebrow,
title, optional trailing control and body. `SunnahEmptyState` provides an icon,
title and explanatory text; it renders an action only when both a visible label
and callback are supplied. These primitives do not fetch, parse or hold
content records.

## Responsive layout contract

| Surface | Compact / narrow | Medium and wide | Tested boundary |
| --- | --- | --- | --- |
| Mobile shell | The four-item bottom navigation remains visible: Hari Ini, Teroka, Simpanan and Tetapan. Scrollable screens retain their own safe insets and page padding. | The same bottom navigation remains the current mobile pattern; content is centered and capped at 560 logical pixels rather than stretched. | 360x800 mobile viewport and large text interaction |
| Onboarding | Centered, scrollable first-launch form | Same form, capped at 560 logical pixels | Shared mobile frame |
| Daily/status/detail | Status-only card and detail page; no record route parameter or content payload | Same status-only state, capped at 560 logical pixels | Static route and card tests |
| Admin below 960 | App bar plus drawer navigation | Same drawer pattern until the breakpoint | 959x800 |
| Admin at or above 960 | Not applicable | Extended navigation rail (248 logical pixels); content capped at 1040 logical pixels | 960x800 and 1200x800 |

The mobile shell intentionally has no navigation-rail breakpoint at this stage.
It is Android-first and retains its fixed four-item bottom navigation on the
tested tablet/desktop-sized Flutter surface. Any new responsive pattern needs a
dedicated task, visual review and regression coverage.

## Screen and state matrix

| Surface | Current allowed state | Required interaction and layout |
| --- | --- | --- |
| Onboarding | Local language choice and continue action only | First launch and deep shell routes stay behind completion; form is centered and scrollable. |
| Hari Ini | Unavailable approved-content status only | Primary heading, status card and explicit status action; no fallback content. |
| Daily status detail | Unavailable status only | Static route, labelled back action and no item identifier. |
| Teroka / Simpanan | Honest empty states | Plain-language empty state; no fabricated collection, bookmark or history. |
| Tetapan | Device-local display controls | Language, theme, reduced motion and text size use the allowlisted preference store. |
| Admin shell | Backend-setup state only | Drawer/rail navigation and empty setup state; it does not claim authentication, role access, source records or approval capability. |

## Accessibility and interaction requirements

- Use a visible text label, not colour alone, for a state or action. Icons
  complement text rather than replacing it.
- Each page-level heading is marked as a semantic header. Mobile primary
  navigation has the localized semantic label. The Daily back action has a
  localized button label. Admin drawer and rail navigation are grouped under
  the `Navigasi admin` semantic label.
- Material controls retain their platform focus, keyboard and assistive
  technology behaviour. No custom focus trap or gesture-only action is added.
- The mobile preference multiplier composes with the platform text scaler; it
  must not flatten nonlinear OS scaling. The shell also respects OS reduced
  motion and the local reduced-motion preference.
- All currently rendered status and empty states use text plus iconography, and
  their scrollable containers must remain usable at a 150% text scale in the
  supported mobile test surface.
- Mobile shell UI is currently BM/English. Full RTL behaviour, Arabic text
  presentation, broader keyboard traversal and assistive-technology audits are
  deferred to PDX-03 and QLT-02; this specification must not be read as a
  claim that they are complete.

## Regression evidence

The following tests protect this contract without adding a data fixture:

- `packages/design_system/test/sunnah_theme_test.dart` covers palette/layout
  tokens, Material 3 theme settings, shared content frame and component action
  behaviour.
- `apps/mobile/test/app_test.dart` covers the four-item navigation, semantic
  navigation label, unavailable Daily flow, readable content frame and a 150%
  text-scale status action.
- `apps/admin/test/app_test.dart` covers the exact 959/960 drawer-to-rail
  boundary, named admin navigation semantics, selected rail destination, rail
  width and maximum content width.

Run `npm run check:flutter` from the repository root after changes to this
contract. Broader localization, RTL, integration, screen-reader and security
testing remain separately scheduled work.
