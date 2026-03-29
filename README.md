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
