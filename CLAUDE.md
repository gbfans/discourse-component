# CLAUDE.md — GBFans Discourse Component

Read `AGENTS.md` first before making any changes. It contains the architecture, file structure, and conventions.

## Rules

- Every exported function/component needs a JSDoc comment
- Match the Next.js site pixel-perfectly (see AGENTS.md and INSTRUCTIONS.md measurements)
- Never use `@service siteSettings` — use the global `settings` object
- Use connector directories for outlet rendering (not `api.renderInOutlet()` which causes duplication on route transitions)
- Never use CSS `@media` queries for showing/hiding sections — use `this.site.mobileView`
- Test in both desktop Discourse AND an actual mobile device
- The component must work when installed via ZIP upload (no plugin dependencies)
- Use `--gbfans-*` CSS custom properties for all design tokens
- Use BEM-style class names: `.gbfans-block__element--modifier`
- Social icons use `icon()` from `discourse/helpers/d-icon`, not inline SVGs
- Navigation hierarchy uses flat `parent` field in settings, tree built in JS
- New FA icons must also be added to the `svg_icons` setting

## File Modification Checklist

When modifying any `.gjs` file:
1. Add a JSDoc comment on the exported class
2. Verify it works on both desktop and mobile
3. Ensure all hardcoded values come from `settings.yml` where appropriate

When modifying `.scss` files:
1. Use existing CSS custom properties from `:root`
2. Don't add `@media` queries for show/hide — only for sizing
3. Test that `--gbfans-chrome-height` offsets are correct

## Key Architecture Decisions

- **Issue 3 (auth/search):** Discourse's native header icons are CSS-repositioned into the top bar. Mobile.scss resets this positioning. Do not recreate Discourse's auth or search.
- **Issue 4 (sidebar):** Forced visible on desktop via CSS. Toggle hidden. On mobile, native Discourse hamburger behavior is preserved.
- **Nav dropdowns:** CSS-only hover, built from flat `nav_links` setting with `parent` field. Items with `url: "#"` are rendered as group headers.
