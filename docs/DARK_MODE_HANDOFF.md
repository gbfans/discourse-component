# Dark Mode Implementation — Handoff Instructions

> Handoff for the next agent/developer implementing dark mode in the GBFans
> Discourse theme component. Assumes you have access to the **Next.js site
> (gbfans.com) source**, which is the design source of truth.

## Goal

Make the GBFans Discourse theme component support a **user-selectable dark
mode** that matches the dark mode already present on the Next.js site
(gbfans.com). Decisions already made with the site owner:

- **Approach: derive from the Discourse color palette** (do not hardcode a
  parallel dark set).
- **Activation: user-selectable** (users choose light/dark in Discourse
  preferences).
- **Parity: match the Next.js dark mode exactly.** The Next.js `globals.css`
  is the source of truth — read its dark values and mirror them. Per
  `CLAUDE.md` / `AGENTS.md`, the two sites must stay in tandem; **do not
  invent dark colors.**

## Why it doesn't work today (the blockers)

The component was built to force one fixed light palette. Three things in
`common/common.scss` each independently defeat dark mode.

> **Two-file sync gotcha:** `common/common.scss` is the file Discourse
> actually compiles/loads. The `scss/_*.scss` partials
> (`_tokens.scss`, `_layout.scss`, …) are **hand-kept mirror copies that are
> NOT compiled** (nothing `@import`s them). Every change below must be made in
> **both** the `common/common.scss` copy **and** the matching `scss/_*.scss`
> partial, or they drift.

1. **It overwrites Discourse's palette with `!important`.**
   In `common/common.scss` (mirror: `scss/_tokens.scss`):
   ```scss
   :root {
     --primary:   var(--gbfans-text)    !important;  // clobbers dark palette back to #000
     --secondary: var(--gbfans-surface) !important;  // clobbers back to #fff
     --tertiary:  var(--gbfans-brand)   !important;
     --header_background: var(--gbfans-header-bg) !important;
     --header_primary:    var(--gbfans-header-text) !important;
   }
   ```
   This is the primary reason editing the "GBFans Dark" palette in Admin does
   nothing — the component forces the light values back on top. **Delete this
   whole block** (the dependency should flow the other way; see below).

2. **Hardcoded `--gbfans-*` tokens** in the `:root` block don't react to the
   scheme (`--gbfans-surface: #ffffff`, `--gbfans-text: #000000`, etc.).

3. **`html { color-scheme: light !important }`** (mirror: `scss/_layout.scss`)
   forces the browser UA into light mode (form controls, scrollbars).
   **Change to `color-scheme: light dark;`** (no `!important`).

## Core idea: invert the dependency

- **Today:** hardcoded `--gbfans-*` → forced into `--primary` / `--secondary`.
- **Change to:** the Discourse palette (`--primary`, `--secondary`,
  `--tertiary`, and their auto-generated shades) **feeds** `--gbfans-*`.

Then whatever scheme is active (light, or the admin's "GBFans Dark") drives the
component automatically, and user-selectable dark "just works" with **no scheme
detection needed in CSS**.

Discourse auto-derives shade variables from every palette — use them so
surfaces / borders / muted text flip automatically:
`--primary`, `--primary-low`, `--primary-low-mid`, `--primary-medium`,
`--primary-high`, `--secondary`, `--secondary-low`, `--secondary-high`,
`--tertiary`, `--quaternary`, `--header_background`, `--header_primary`,
`--highlight`, `--danger`, `--success`, `--love`.

## Token-by-token migration

For each `--gbfans-*` token: first read the corresponding **light and dark**
value from the Next.js `globals.css` (`@theme` block + its dark variant /
`.dark` selector). Then map to a palette var where one fits (auto-flips), or
set the value in the **Discourse dark palette** where it's brand-specific.
Suggested mapping — **verify each against the Next.js dark values**:

| Token | Light (current) | Suggested source | Notes |
|---|---|---|---|
| `--gbfans-text` | `#000000` | `var(--primary)` | flips to light-on-dark automatically |
| `--gbfans-surface` | `#ffffff` | `var(--secondary)` | main panel background |
| `--gbfans-surface-alt` | `#f0f0f0` | `var(--primary-very-low)` / `--secondary-high` | verify vs Next.js |
| `--gbfans-surface-muted` | `#f4f4f4` | `var(--primary-very-low)` | |
| `--gbfans-border` | `#dddddd` | `var(--primary-low)` | |
| `--gbfans-border-light` | `#e3e3e3` | `var(--primary-very-low)` | |
| `--gbfans-text-secondary` | `#555555` | `var(--primary-high)` | |
| `--gbfans-text-muted` | `#888888` | `var(--primary-medium)` | |
| `--gbfans-text-soft` | `#666666` | `var(--primary-high)` | |
| `--gbfans-brand` / `-hover` | `#ed1c24` / `#d12e2e` | `var(--tertiary)` (+ a darken for hover) | Ghostbusters red — same both modes |
| `--gbfans-page-bg` | `#353535` | **Next.js dark value** | tiled bg behind panel; already dark — check dark variant |
| `--gbfans-header-bg` / `-text` | `#000` / `#fff` | `var(--header_background)` / `var(--header_primary)` | set both in the dark palette |
| `--gbfans-nav-*` | greys | Next.js dark values or `--primary-*` shades | brand-specific bar |
| `--gbfans-footer-*` | dark greys | **Next.js dark values** | footer already dark; confirm dark-mode treatment |

**Rule of thumb:** derivable neutrals → palette shades; brand-specific colors
(header / nav / footer / brand red) → explicit values taken from Next.js,
placed either directly in the token or in the Discourse dark palette slots.

## Background images (don't forget these)

The component sets two remote images baked for a light background:

- Tiled page bg: `--gbfans-bg-tiled-url`, fallback
  `https://www.gbfans.com/GBFans-Background-Tiled2.png`
  (`common/common.scss` `html` rule / `scss/_layout.scss`).
- Footer art: `--gbfans-footer-bg-url`, fallback
  `https://www.gbfans.com/mini-pufts-footer.png`
  (`common/common.scss` footer rule / `scss/_footer.scss`).

These are injected as CSS custom properties from the header connector
(`javascripts/discourse/connectors/above-site-header/gbfans-header.gjs`, the
style-injection constructor) using `*_url` settings in `settings.yml`. Check
whether the Next.js dark mode uses different background art. If so, add
dark-image settings and swap them — cleanest via the same JS injection keyed
off the active scheme, or a scheme-gated CSS override. If the tiled texture is
unchanged in dark, no change needed.

## How "user-selectable" activates (Discourse mechanics)

- The **light and dark palettes themselves are configured in Discourse Admin**
  (the owner already created a "GBFans Dark" palette). Set its
  `primary / secondary / tertiary / header_background / header_primary / …`
  slots to the Next.js dark values.
- With the derive-from-palette approach, the **component is scheme-agnostic** —
  it never needs to detect dark; it just reads `--primary` / `--secondary` /
  etc., which already reflect whichever scheme is active.
- For user selection: ensure the theme's color scheme(s) are user-selectable
  (Admin → Customize → Themes → assign a default light scheme and a dark
  scheme, user-selectable enabled). Users then pick it in
  Preferences → Interface.
- Because activation is a manual user choice (not OS), **do not rely on
  `@media (prefers-color-scheme: dark)`** for the brand overrides — it won't
  match a manual toggle. Prefer palette-derived values, which flip regardless
  of how the scheme was chosen.

## Steps

1. In the Next.js repo, open `globals.css` (or wherever the `@theme` / dark
   tokens live). Record every light and dark color value.
2. In **both** `common/common.scss` and the `scss/_*.scss` mirrors:
   - Delete the `:root { --primary … !important }` override block.
   - Change `color-scheme: light !important` → `color-scheme: light dark;`.
   - Rewrite the `--gbfans-*` token definitions to derive from palette
     vars/shades (table above), using explicit Next.js dark values only for
     brand-specific tokens.
   - Audit for other hardcoded light colors / `!important` fills (e.g.
     `body { background-color: var(--gbfans-surface) !important }`) — fine once
     the token is palette-derived, but confirm nothing pins a literal light
     color.
3. In Discourse Admin, set the "GBFans Dark" palette slots to the Next.js dark
   values (header / nav / footer brand colors especially).
4. Handle dark background images if the Next.js dark mode differs.
5. Keep the JSDoc / BEM / `settings.yml` conventions from `CLAUDE.md`.

## Testing

- Toggle between light and "GBFans Dark" as a user (Preferences → Interface) on
  **desktop and a real mobile device**. (Chrome responsive mode won't load
  `mobile/mobile.scss` — though note that file is intentionally empty here;
  responsive styles live in `common.scss` behind `@media`.)
- Verify: page/tiled bg, main panel, header bar, nav bar + dropdowns, footer,
  buttons, composer, sidebar (already dark-themed — make sure it doesn't
  double-darken), links / focus rings.
- Confirm **light mode is unchanged** from today (regression check against the
  current pixel-matched look).

## Constraints / gotchas

- **Two-file sync:** `common/common.scss` is loaded; `scss/_*.scss` are
  hand-kept mirrors. Change both.
- **Design parity is mandatory:** match Next.js; do not invent dark colors.
- Don't use `@service siteSettings` (use the global `settings` object); don't
  use `api.renderInOutlet()` (use connector directories); icons via the
  `icon()` helper. (See `CLAUDE.md`.)
- The composer positioning rules (`#reply-control`) live in these same two
  files — they don't touch color tokens, so no conflict, but be aware they're
  there.
