# GBFans Discourse Theme Component

A branded header and footer for the GBFans Discourse forum, matching the design of [gbfans.com](https://gbfans.com).

## Features

- Branded top bar with configurable CTA and social links
- Sticky logo header with responsive sizing
- Desktop navigation bar with hover dropdown menus
- Branded footer with community description, social links, and search
- All content configurable via Discourse admin settings
- Pixel-perfect match to the Next.js site design
- Mobile-responsive with Discourse-native mobile support
- Discourse header icons (search, chat, profile) integrated into the top bar
- Sidebar forced visible on desktop with proper sticky offset

## Installation

### Via GitHub URL
1. Go to Discourse Admin → Customize → Themes
2. Click "Install" → "From a git repository"
3. Enter the repository URL
4. Add the component to your active theme

### Via ZIP Upload
1. Download or build a ZIP of this repository
2. Go to Discourse Admin → Customize → Themes
3. Click "Install" → "From your device"
4. Upload the ZIP file
5. Add the component to your active theme

## Configuration

All settings are editable in Discourse Admin → Customize → Themes → GBFans Theme → Settings.

| Setting | Type | Description |
|---------|------|-------------|
| `gbfans_site_url` | string | Base URL of the main site (no trailing slash) |
| `brand_name` | string | Brand name for headings and alt text |
| `logo_url` | string | Header logo path (appended to site URL) |
| `footer_logo_url` | string | Footer logo path (appended to site URL) |
| `top_bar_cta_text` | string | Call-to-action text in the top bar |
| `top_bar_cta_url` | string | CTA link URL (relative to site URL) |
| `nav_links` | objects | Navigation links with dropdown hierarchy |
| `social_links` | objects | Social media links with FA icon names |
| `svg_icons` | list | FA icon classes to include in the icon sprite |
| `footer_description` | string | Community description in the footer |
| `footer_join_url` | string | JOIN US link URL (relative to site URL) |

### Navigation Links

Navigation uses a flat list with a `parent` field to build dropdown hierarchy:
- **Top-level items:** `parent` is empty
- **Dropdown children:** `parent` matches a top-level item's `text`
- **Group headers:** items with a `parent` and `url` set to `#`

### Social Links

Each social link has a `name`, `url`, and `icon` (Font Awesome name like `fab-instagram`). New icons must also be added to the `svg_icons` setting.

## Dark Mode

The component derives its colors from the active Discourse color palette instead of hardcoding a parallel dark set. `--gbfans-*` tokens read from `--primary`/`--secondary`/`--tertiary`/`--quaternary`/`--header_background`/`--header_primary` and their auto-generated shades (`-low`/`-low-mid`/`-medium`/`-high`), so whichever palette a user selects in Preferences → Interface flows through automatically.

To enable dark mode:

1. In Discourse Admin → Customize → Colors, configure (or confirm) the "GBFans Dark" palette. Set `primary`, `secondary`, `tertiary`, `header_background`, and `header_primary` to match the dark values in `apps/site/app/globals.css`'s `[data-theme="dark"]` block on the Next.js site.
2. Set the palette's `quaternary` slot to `#050505` in the dark palette and `#353535` in the light/default palette — this drives `--gbfans-page-bg` (the tiled backdrop behind the panel), which has no dedicated Discourse palette role.
3. Set the palette's `selected` slot to `#0f0f0f` in the dark palette and `#f0f0f0` in the light/default palette — this drives `--gbfans-nav-bg` (the desktop nav bar). It's borrowed the same way as `quaternary` because Next.js's nav bar is always darker than the surface behind it in both themes, which Discourse's auto-derived `-low`/`-high` shades can't express (they always shift toward `--primary`, flipping direction between themes).
4. In Admin → Customize → Themes, make sure the theme's color scheme is set to user-selectable and the dark scheme is assigned, so users can pick it from Preferences → Interface.

Brand-locked colors (the Ghostbusters red accent, the footer) don't flip between themes on the Next.js site either, so they stay literal `--gbfans-*` values rather than palette-derived ones. See the token comments in `common/common.scss` (and its mirror `scss/_tokens.scss`) for the full mapping.

## Architecture

- **Framework:** Discourse theme component (Glimmer/GJS)
- **Outlets:** `above-site-header` (header), `below-footer` (footer)
- **Responsive:** `this.site.mobileView` for show/hide, CSS `@media` for sizing
- **Styling:** SCSS with `--gbfans-*` CSS custom properties
- **Icons:** Discourse `d-icon` helper (not inline SVGs)

See `AGENTS.md` for detailed architecture documentation.

## Development

1. Make changes to the component files
2. Build a ZIP: `zip -r gbfans-theme.zip about.json settings.yml common/ mobile/ javascripts/`
3. Upload in Discourse Admin → Customize → Themes → Install
4. Test on both desktop and mobile devices

## License

Copyright GBFans LLC. All rights reserved.
