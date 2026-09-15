---
name: OnTheWay
description: A calm, map-led marketplace for trusted help already moving nearby.
colors:
  app-background: "light-dark(#FAFAF7, #101210)"
  app-surface: "light-dark(#FFFFFF, #1C1F1B)"
  app-surface-alt: "light-dark(#F4F1EC, #252922)"
  app-line: "light-dark(#E8E4DC, #3D4239)"
  app-ink: "light-dark(#1B1D21, #F5F6F2)"
  app-secondary-ink: "light-dark(#5C626C, #B9BFB5)"
  brand-navy: "light-dark(#1F2A44, #ADBEE7)"
  brand-green: "light-dark(#2F7650, #63B88D)"
  accent-blue: "light-dark(#356EA6, #76A8DC)"
  warm-amber: "light-dark(#8E5712, #E9AF56)"
  app-danger: "light-dark(#C0533F, #EF8471)"
  muted-plum: "light-dark(#7A5478, #CA9DC6)"
  coffee-brown: "#8F6A45"
  constant-white: "#FFFFFF"
typography:
  display:
    fontFamily: "SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "34px"
    fontWeight: 700
  headline:
    fontFamily: "SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "17px"
    fontWeight: 600
  title:
    fontFamily: "SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "22px"
    fontWeight: 700
  body:
    fontFamily: "SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "17px"
    fontWeight: 400
  label:
    fontFamily: "SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "12px"
    fontWeight: 600
rounded:
  compact: "10px"
  card: "14px"
  message: "18px"
  emblem: "20px"
  pill: "999px"
spacing:
  micro: "4px"
  tight: "6px"
  xs: "8px"
  compact: "10px"
  sm: "12px"
  control: "14px"
  md: "16px"
  section: "18px"
  lg: "20px"
  xl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.brand-green}"
    textColor: "{colors.constant-white}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
    padding: "10px 20px"
    height: "44px"
  button-primary-compact:
    backgroundColor: "{colors.brand-green}"
    textColor: "{colors.constant-white}"
    typography: "{typography.headline}"
    rounded: "{rounded.pill}"
    padding: "10px 14px"
    height: "44px"
  button-secondary:
    backgroundColor: "{colors.app-surface-alt}"
    textColor: "{colors.app-ink}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
    padding: "10px 20px"
    height: "44px"
  card:
    backgroundColor: "{colors.app-surface}"
    textColor: "{colors.app-ink}"
    rounded: "{rounded.card}"
    padding: "16px"
  status-pill:
    backgroundColor: "{colors.app-surface-alt}"
    textColor: "{colors.brand-green}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "6px 10px"
  field:
    backgroundColor: "{colors.app-surface-alt}"
    textColor: "{colors.app-ink}"
    typography: "{typography.body}"
    rounded: "{rounded.compact}"
    padding: "12px"
    height: "44px"
  map:
    rounded: "{rounded.card}"
    height: "260px"
  role-switch:
    backgroundColor: "{colors.app-surface-alt}"
    textColor: "{colors.app-ink}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
    padding: "4px"
    height: "44px"
  map-annotation:
    backgroundColor: "{colors.app-surface}"
    textColor: "{colors.app-ink}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "6px 8px"
  bottom-primary-action:
    backgroundColor: "{colors.brand-green}"
    textColor: "{colors.constant-white}"
    rounded: "{rounded.pill}"
    height: "52px"
    width: "52px"
---

# Design System: OnTheWay

## Overview

**Creative North Star: "The Neighborhood Wayfinder"**

OnTheWay feels like a dependable local map annotated by a calm neighbor: warm off-white ground, high-contrast ink, restrained color signals, and one clear action at a time. The interface is information-rich but never dashboard-like; native typography, controls, navigation, and SF Symbols keep the marketplace immediately legible on Apple devices.

The map is the visual proof of proximity and route fit, while rounded, outlined cards turn nearby people, tasks, money, and lifecycle steps into scannable units. Sage green carries action, availability, route fit, and successful progress; deep navy anchors selection and trust. Amber, blue, plum, and coffee brown identify categories or supporting meaning without competing with the primary action.

Voice is calm, direct, trustworthy, local, and human. Labels use concrete verbs and plain outcomes—“Create a Task,” “Accept Task,” “Start Helping Now”—while supporting copy explains timing, detour, payment, and privacy before asking for commitment. Sensitive details are described honestly and revealed progressively.

**Key Characteristics:**

- Map-led discovery with approximate pre-match location signals.
- Warm adaptive surfaces with deep neutral ink and hairline boundaries.
- Sage-green actions and positive status; navy selection and trust.
- Native SF typography, SF Symbols, navigation, dialogs, pickers, and controls.
- Compact rounded cards, capsules, and circular identity/action moments.
- Transparent task state, route effort, pricing, consent, and privacy copy.

## Colors

The palette is warm, grounded, and semantic: neutral surfaces carry most of every screen, while brand and category colors communicate state rather than decorate.

### Primary

- **Route Sage** (`brand-green`, `light-dark(#2F7650, #63B88D)`): primary buttons, app tint, availability, positive status, route match, progress, selected completion, and live-location emphasis.

### Secondary

- **Trust Navy** (`brand-navy`, `light-dark(#1F2A44, #ADBEE7)`): selected filters and tabs, identity marks, supporting icons, requester status, and outgoing message bubbles.

### Tertiary

- **Verified Blue** (`accent-blue`, `light-dark(#356EA6, #76A8DC)`): verification, time/detour metadata, delivery-category identity, and informational emphasis.
- **Warm Amber** (`warm-amber`, `light-dark(#8E5712, #E9AF56)`): ratings, store errands, and warm caution-adjacent emphasis.
- **Muted Plum** (`muted-plum`, `light-dark(#7A5478, #CA9DC6)`): return/drop-off identity.
- **Coffee Brown** (`coffee-brown`, `#8F6A45`): the coffee category’s stable identity color.
- **Measured Coral** (`app-danger`, `light-dark(#C0533F, #EF8471)`): destructive actions, validation failures, cancellation, and unread urgency only.

### Neutral

- **Warm Canvas** (`app-background`, `light-dark(#FAFAF7, #101210)`): page background and the dominant visual field.
- **Clean Card** (`app-surface`, `light-dark(#FFFFFF, #1C1F1B)`): cards, received messages, and primary raised surfaces.
- **Soft Field** (`app-surface-alt`, `light-dark(#F4F1EC, #252922)`): inputs, unselected chips, and quiet control fills.
- **Warm Hairline** (`app-line`, `light-dark(#E8E4DC, #3D4239)`): card outlines, dividers, and control boundaries.
- **Near-Black Ink** (`app-ink`, `light-dark(#1B1D21, #F5F6F2)`): titles, primary content, prices, and dense data.
- **Slate Metadata** (`app-secondary-ink`, `light-dark(#5C626C, #B9BFB5)`): descriptions, timestamps, helper facts, and supporting labels.
- **Constant White** (`constant-white`, `#FFFFFF`): text and symbols on filled brand controls.

**The Semantic Accent Rule.** Green means action, availability, route fit, or success; navy means selection, identity, or trust; tertiary hues remain scoped to categories and supporting status.

**The Adaptive Pair Rule.** Shared surfaces, lines, ink, and semantic accents use their implemented light/dark pairs. Never substitute a light-only raw value for a shared UI role.

## Typography

**Display Font:** SF Pro Display through SwiftUI’s native text styles
**Body Font:** SF Pro Text through SwiftUI’s native text styles
**Label Font:** SF Pro Text; numerical summaries opt into monospaced digits

**Character:** Familiar, confident, and highly scannable. Weight creates hierarchy; the system never depends on a custom brand face, manual tracking, or fixed line heights.

### Hierarchy

- **Display** (bold, SwiftUI `.largeTitle`, 34-point default): top-level marketplace titles, completion outcomes, large balances, and decisive state messages.
- **Title** (bold or semibold, primarily `.title2`, 22-point default): task identities, pricing, and focused screen summaries; `.title3` handles compact subheads and amounts.
- **Headline** (semibold, `.headline`, 17-point default): card titles, section headings, names, and important control labels.
- **Body** (regular or semibold, `.body`, 17-point default): explanatory copy and full-width primary actions.
- **Label** (semibold, `.caption`/`.caption2`, 12/11-point defaults): metadata, pills, progress captions, and compact uppercase metrics.

Currency, times, route percentages, balances, PINs, and metric values use monospaced digits so updates do not shift the layout. Dynamic Type is implemented through semantic SwiftUI styles; do not replace them with hard-coded point sizes.

**The Native Scale Rule.** Use SwiftUI text styles and weight modifiers as the type system. Fixed sizes are reserved for symbol geometry and bounded controls, not readable text.

**The Data Stability Rule.** Apply monospaced digits to values that compare, count, update, or align; keep surrounding prose in the default proportional face.

## Layout

The standard scrollable screen scaffold uses a single centered content column capped at 720 points, with 16-point horizontal insets and 24 points of bottom breathing room. Marketplace and form surfaces keep this structure on iPad: the column grows until the cap and stays centered rather than becoming a loose multi-column dashboard.

Primary screen stacks usually advance in 16-, 18-, or 20-point steps. Cards use 12–16 points of internal padding; compact metadata clusters use 3–8 points. Top-level marketplace screens start with location and role context, then a large title, map or primary state, scannable cards, and a dominant action when needed.

The map is 260 points tall on discovery surfaces and uses the card radius. The custom bottom bar sits in a bottom safe-area inset; its four destinations flank a raised 52-point circular creation action. Hierarchical screens use `NavigationStack`, inline navigation titles, toolbars, sheets, alerts, and confirmation dialogs. All routine controls target at least 44 by 44 points.

Dynamic Type may reflow text and cards. Map annotations and the bottom bar deliberately clamp their internal type to the small-through-large range to preserve map legibility and navigation geometry; accessibility labels carry their meaning. At accessibility sizes, nonessential bottom-bar captions may be omitted while the icon retains its accessible name.

**The Centered Column Rule.** New screens inherit the 16-point inset and 720-point maximum before inventing a different grid.

**The Route-First Rule.** On marketplace discovery, location, role, route/proximity evidence, and the next action appear before secondary detail.

## Elevation & Depth

The system is flat and outlined by default. Warm tonal changes and one-point `app-line` strokes separate the canvas, cards, fields, and dividers; ordinary cards do not cast shadows. Native bar material and regular material are reserved for the bottom navigation and compact overlays that must remain readable over the map.

### Shadow Vocabulary

- **Welcome Emblem** (SwiftUI navy at 18% opacity, radius 15, y 8): a single soft identity lift on the welcome mark.
- **Create Action** (SwiftUI green at 25% opacity, radius 8, y 4): separates the raised circular New action from the bottom bar.

**The Flat-by-Default Rule.** Borders and tonal surfaces create structure; shadows belong only to the welcome identity mark and the raised global creation action.

**The Map Material Rule.** Translucent material appears only where labels overlay live map content or where the system bar needs native separation.

## Shapes

Continuous 14-point rounded rectangles define cards, map clipping, and grouped containers. Compact fields, icon tiles, and metric cards use 10-point corners. Message bubbles use 18-point corners, the welcome emblem uses 20 points, and buttons, pills, filters, avatars, map markers, and the global creation action use capsules or circles.

One-point outlines use `app-line`; status pills use a subtler same-hue outline over a 10%-opacity tint fill. Geometry stays soft but disciplined—rounded rectangles for information, capsules for compact state/action, and circles for people, presence, or singular global action.

**The Shape-by-Meaning Rule.** Use cards for grouped information, capsules for actions and transient status, and circles for identity, presence, or one-icon actions.

## Components

### Buttons

- **Shape:** full-width and compact actions are capsules with a 44-point minimum height.
- **Primary:** `brand-green` with constant-white text, semibold native type, 20-point horizontal padding; compact actions use 14-point horizontal padding. Destructive primary actions swap the fill to `app-danger` without changing geometry.
- **Pressed:** opacity falls to 82% and scale to 98.5% over a 0.12-second ease-out. Reduce Motion-sensitive presentation effects are removed where implemented.
- **Secondary:** `app-surface-alt` fill, `app-ink` text, and a one-point `app-line` capsule stroke; the pressed fill becomes `app-line`.
- **Disabled:** preserve layout and reduce opacity to 45% where an unavailable selection blocks progress.

### Chips

- **Status:** caption-weight text with optional SF Symbol, 10-point horizontal and 6-point vertical padding, a 10%-opacity semantic tint fill, and a 20%-opacity outline.
- **Filter:** 36-point minimum height. Selected chips use `brand-navy` with constant-white text; unselected chips use `app-surface-alt`, `app-secondary-ink`, and an `app-line` outline.
- **State:** selected controls expose the native selected accessibility trait; positive progress remains green, not navy.

### Cards / Containers

- **Corner Style:** continuous 14-point corners; compact metrics use 10 points.
- **Background:** `app-surface` on `app-background`.
- **Shadow Strategy:** none for ordinary cards; see Elevation & Depth.
- **Border:** one-point `app-line` stroke.
- **Internal Padding:** 16 points by default, 12–15 points for denser rows and marketplace cards.
- **Behavior:** tappable cards use a plain button style, combine or contain their VoiceOver children intentionally, and add an outcome-oriented accessibility hint.

### Inputs / Fields

- **Style:** `app-surface-alt` fill, 10-point corners, 12–14 points of inset, and native body text. Labels sit above in semibold caption or subheadline text.
- **Focus:** use native keyboard focus and field semantics; no decorative focus glow is implemented.
- **Error / Disabled:** validation copy uses `app-danger` with `exclamationmark.circle.fill`; unavailable actions remain in place at reduced opacity.
- **Controls:** segmented pickers, menus, date pickers, toggles, sliders, steppers, alerts, and confirmation dialogs remain native SwiftUI controls.

### Navigation

- **Role switch:** a native segmented picker labeled “Marketplace mode” switches between “Need Help” and “Help & Earn.”
- **Hierarchy:** `NavigationStack` provides push navigation, inline deep-screen titles, toolbars, and the system back behavior.
- **Bottom bar:** Home, Activity, Inbox, and Profile are persistent destinations. The selected destination uses `brand-navy`; unselected destinations use `app-secondary-ink`; the raised green New action is centered and offset upward.

### Marketplace Map

The standard flat Apple map removes points of interest and traffic so task/helper annotations remain dominant. Approximate annotations combine a material capsule with a small category- or availability-colored marker. Requester maps show helper readiness; helper maps show category and reward. Compact material badges communicate nearby count, Live state, and average response without covering the route field.

### Lifecycle & Trust States

Route match, detour, timing, payment authorization, helper identity, consent changes, cancellation outcomes, and delivery PINs are formatted as cards, status pills, progress views, and labeled value rows. Before acceptance, locations are approximate and sensitive instructions are explicitly locked; after acceptance, exact task details and privacy-protected communication can appear. State copy names the outcome rather than implying background magic.

### Motion & Feedback

Authentication uses a 0.20-second ease-out crossfade, the welcome reveal uses a 0.35-second ease-out, and search progress updates use a 0.30-second ease-out. Primary and secondary button presses use the 0.12-second treatment above. Welcome and search animations read `accessibilityReduceMotion` and become immediate when requested; navigation otherwise follows native transitions.

## Do's and Don'ts

### Do:

- **Do** begin discovery screens with current-area context, requester/helper mode, and map or route evidence.
- **Do** use adaptive semantic colors and verify both light and dark appearances.
- **Do** preserve the 14-point card, 10-point compact-control, capsule-action, and circular-identity grammar.
- **Do** use native SwiftUI text styles, SF Symbols, navigation, pickers, dialogs, safe areas, and at least 44-point touch targets.
- **Do** label icon-only controls and map content for VoiceOver, combine dense rows thoughtfully, mark selections, and honor Reduce Motion.
- **Do** show approximate location before a match and explain when exact address, identity, reference, and handoff details unlock.
- **Do** write short, concrete labels and pair marketplace claims with visible facts such as detour, response time, route match, price, or state.

### Don't:

- **Don't** use category accents as competing primary actions or decorative color washes.
- **Don't** add shadows to routine cards, fields, or list rows; use tonal contrast and the one-point hairline.
- **Don't** replace SF typography or SF Symbols with web fonts, icon packs, or manually fixed text sizes.
- **Don't** replace native navigation, segmented controls, menus, alerts, sheets, toggles, sliders, steppers, or date pickers with web-shaped imitations.
- **Don't** expose exact locations, full order references, personal contact details, or handoff instructions before the lifecycle permits them.
- **Don't** encode state with color alone; retain text, symbols, values, and accessibility traits.
- **Don't** shrink routine controls below 44 points or let Dynamic Type collide with the map and bottom navigation.
