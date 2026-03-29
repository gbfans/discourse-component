# AGENTS.md — GBFans Discourse Component

## Architecture Overview

This is a **Discourse theme component** (not a plugin). It provides a branded header and footer for the GBFans Discourse forum, pixel-perfect matching the design of the main Next.js site at gbfans.com.

Theme components are installed via ZIP upload or GitHub URL in Discourse Admin → Customize → Themes → Install.

## File Structure

```
├── about.json                         # Component metadata (component: true)
├── settings.yml                       # Admin-configurable settings
├── common/
│   └── common.scss                    # Desktop + shared styles
├── mobile/
│   └── mobile.scss                    # Mobile-only style overrides
└── javascripts/discourse/
    ├── initializers/
    │   └── gbfans-init.js              # Registers components into Discourse outlets
    └── components/
        ├── gbfans-header.gjs           # Header (top bar + logo + nav, responsive)
        ├── gbfans-header-mobile.gjs    # Mobile-only header (logo only)
        ├── gbfans-nav-desktop.gjs      # Desktop nav with hover dropdowns
        ├── gbfans-footer.gjs           # Footer (branding + copyright)
        └── gbfans-social-icons.gjs     # Shared social icon links
```

## How Settings Work

All configurable values are defined in `settings.yml`. Access them in `.gjs` components via the global `settings` object:

```javascript
const url = settings.gbfans_site_url;
```

**Important:** Do NOT use `@service siteSettings` — that's for Discourse plugins, not theme components.

### Navigation Links (`nav_links`)

Uses `type: objects` with a flat structure and a `parent` field for hierarchy. Discourse doesn't support nested objects, so the component builds a tree in JavaScript:

```javascript
const topLevel = links.filter(l => !l.parent);
topLevel.map(item => ({
  ...item,
  children: links.filter(l => l.parent === item.text),
}));
```

Items with `url: "#"` and a `parent` are rendered as group headers (non-clickable separators like "Primary Universe").

### Social Links (`social_links`)

Uses Font Awesome icons via Discourse's `icon` helper (imported from `discourse/helpers/d-icon`). Icon names use the FA prefix format: `fab-instagram`, `fab-facebook`, etc.

New icons must also be added to the `svg_icons` setting so Discourse includes them in the icon sprite.

## Plugin Outlets

Components are injected into Discourse via `api.renderInOutlet()`:

| Outlet | Component | Purpose |
|--------|-----------|--------|
| `above-site-header` | `GbfansHeader` | Branded header above Discourse's native header |
| `below-footer` | `GbfansFooter` | Branded footer below Discourse's content |

## Responsive Behavior

**Always use `this.site.mobileView` for show/hide logic**, not CSS media queries.

Discourse loads `mobile/mobile.scss` only for actual mobile user agents. Chrome's responsive mode does NOT trigger mobile SCSS loading. The `this.site.mobileView` property in components matches Discourse's mobile detection.

CSS `@media` queries are fine for sizing adjustments (logo dimensions, padding) within elements that are already visible.

## CSS Conventions

- All custom properties use `--gbfans-*` prefix
- Class names use BEM-style: `.gbfans-component__element--modifier`
- Design tokens in `:root` match the Next.js site's `globals.css`
- `--gbfans-chrome-height` controls sticky offsets (108px desktop, 70px mobile)

## Discourse Header Integration (Issue 3)

Discourse's native header icons (search, chat, notifications, profile) are repositioned into the GBFans top bar using CSS:

- `.d-header-wrap` is absolutely positioned at `top: 0; right: 0; height: 40px`
- `.d-header` is made transparent with `height: 40px`
- `pointer-events: none` on the wrapper, `auto` on `.d-header-icons`
- On mobile, `mobile.scss` resets these to normal positioning

Do NOT try to recreate Discourse's auth, search, or notifications. Use CSS to reposition the native widgets.

## Sidebar Behavior (Issue 4)

The sidebar is forced visible on desktop via `body:not(.mobile-view) .sidebar-wrapper { display: block !important; }`. The toggle button is hidden since the sidebar is always shown.

On mobile, the sidebar toggle is visible and Discourse's native hamburger behavior works normally.

## Testing

1. Build a ZIP: `zip -r gbfans-theme.zip about.json settings.yml common/ mobile/ javascripts/`
2. Upload in Discourse Admin → Customize → Themes → Install → From file
3. Add the component to your active theme
4. Test in desktop browser AND actual mobile device (Chrome responsive mode won't load mobile SCSS)
5. Change settings in Admin → Customize → Themes → GBFans Theme → Settings

## Common Pitfalls

- **Don't use `@service siteSettings`** — use the global `settings` object
- **Don't use CSS media queries for showing/hiding sections** — use `this.site.mobileView`
- **Don't use connector directories** — use `api.renderInOutlet()` in the initializer
- **Don't use `iconNode()`** — use `icon()` helper imported from `discourse/helpers/d-icon`
- **Mobile SCSS only loads for mobile user agents** — Chrome responsive mode won't trigger it
- **New FA icons must be in the `svg_icons` setting** — otherwise they won't appear in Discourse's icon sprite
