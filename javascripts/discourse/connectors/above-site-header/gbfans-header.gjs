import Component from "@glimmer/component";
import { registerDestructor } from "@ember/destroyable";
import { service } from "@ember/service";
import GbfansNavDesktop from "../../components/gbfans-nav-desktop";
import GbfansSocialIcons from "../../components/gbfans-social-icons";

const DEFAULT_GBFANS_SITE_URL = "https://www.gbfans.com";

function gbfansSiteUrl() {
  const rawUrl = settings.gbfans_site_url || DEFAULT_GBFANS_SITE_URL;
  return String(rawUrl).trim().replace(/\/+$/, "") || DEFAULT_GBFANS_SITE_URL;
}

function gbfansMainSiteUrl(path) {
  if (!path) return gbfansSiteUrl();
  if (/^https?:\/\//.test(path)) return path;
  return `${gbfansSiteUrl()}${path.startsWith("/") ? path : `/${path}`}`;
}

/**
 * Injects dynamic image URLs as CSS custom properties.
 * Guarded by element ID to prevent duplicates.
 */
function injectDynamicStyles() {
  if (document.getElementById("gbfans-dynamic-urls")) return;
  const style = document.createElement("style");
  style.id = "gbfans-dynamic-urls";
  style.textContent = `
    :root {
      --gbfans-bg-tiled-url: url("${gbfansMainSiteUrl("GBFans-Background-Tiled2.png")}");
      --gbfans-footer-bg-url: url("${gbfansMainSiteUrl("mini-pufts-footer.png")}");
    }
  `;
  document.head.appendChild(style);
}

/**
 * Discourse's own `.d-header` is CSS-collapsed to 40px (see
 * _discourse-header.scss) so its native header-offset calculation
 * (frontend/discourse/app/lib/offset-calculator.js) writes a 40px
 * `--header-offset` as an INLINE style on <html>. That's far shorter than
 * the real GBFans sticky chrome (logo header + nav tile + nav bar), and
 * that lib reads the inline style directly via
 * `document.documentElement.style.getPropertyValue()` -- bypassing the CSS
 * cascade entirely -- so our stylesheet `!important` override in
 * _tokens.scss never reaches it. Without this, jumping to a permalinked
 * post (e.g. /t/slug/id/23) scrolls short and the sticky header covers the
 * top of the post.
 */
function totalChromeOffsetPx() {
  const raw = getComputedStyle(document.documentElement)
    .getPropertyValue("--gbfans-total-chrome")
    .trim();
  const px = parseInt(raw, 10);
  return Number.isNaN(px) ? 0 : px;
}

function applyHeaderOffset() {
  const desired = `${totalChromeOffsetPx()}px`;
  if (
    document.documentElement.style.getPropertyValue("--header-offset") !==
    desired
  ) {
    document.documentElement.style.setProperty("--header-offset", desired);
  }
}

/**
 * Keeps the inline `--header-offset` pinned to the real GBFans chrome
 * height. A MutationObserver re-asserts it whenever Discourse's own
 * site-header component overwrites it (on initial render and on resize),
 * and a resize listener recomputes it when the responsive chrome height
 * itself changes (desktop/mobile breakpoint).
 */
function watchHeaderOffset() {
  applyHeaderOffset();

  const observer = new MutationObserver(applyHeaderOffset);
  observer.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["style"],
  });
  window.addEventListener("resize", applyHeaderOffset);

  return () => {
    observer.disconnect();
    window.removeEventListener("resize", applyHeaderOffset);
  };
}

/**
 * Keeps the repositioned Discourse header icons (hamburger, search, chat,
 * profile) visible on mobile — including on topic pages.
 *
 * On topic pages Discourse "docks" its header and, on mobile, auto-hides it
 * on scroll-down (sliding `.d-header-wrap` out of view) to free up reading
 * space. This theme has moved those icons onto the always-visible GBFans logo
 * row, so that hide is unwanted. Discourse applies the hide as inline styles
 * on scroll, which can out-rank the theme's author `!important` CSS (inline
 * `!important`, or via a class the CSS doesn't target), so re-assert the
 * pinned position imperatively whenever Discourse mutates the header or the
 * page scrolls. A value is written only when it has actually drifted, so there
 * is no mutation feedback loop. Everything is gated to mobile widths: desktop
 * deliberately lets the icons ride the top bar and scroll away, so the inline
 * overrides are removed again when the viewport crosses back above 767px.
 */
function pinMobileHeaderIcons() {
  const MOBILE = "(max-width: 767px)";
  // The levers Discourse can use to slide/hide the docked header.
  const PINNED = {
    position: "fixed",
    top: "0px",
    "margin-top": "0px",
    transform: "none",
    translate: "none",
  };
  let observer;
  let rafId;
  let pinned = false;

  function apply() {
    const wrap = document.querySelector(".d-header-wrap");
    if (!wrap) return;
    // Discourse may translate the inner `.d-header` rather than the wrap.
    const inner = wrap.querySelector(".d-header");

    if (window.matchMedia(MOBILE).matches) {
      for (const [prop, value] of Object.entries(PINNED)) {
        if (wrap.style.getPropertyValue(prop) !== value) {
          wrap.style.setProperty(prop, value, "important");
        }
      }
      for (const prop of ["transform", "translate"]) {
        if (inner && inner.style.getPropertyValue(prop) !== "none") {
          inner.style.setProperty(prop, "none", "important");
        }
      }
      pinned = true;
    } else if (pinned) {
      // Back on desktop: drop our mobile-only overrides so Discourse wins.
      for (const prop of Object.keys(PINNED)) {
        wrap.style.removeProperty(prop);
      }
      for (const prop of ["transform", "translate"]) {
        inner?.style.removeProperty(prop);
      }
      pinned = false;
    }
  }

  function start() {
    const wrap = document.querySelector(".d-header-wrap");
    if (!wrap) {
      // Header not in the DOM yet — retry on the next frame.
      rafId = requestAnimationFrame(start);
      return;
    }
    apply();
    observer = new MutationObserver(apply);
    observer.observe(wrap, {
      attributes: true,
      attributeFilter: ["style", "class"],
    });
    // Scroll is what actually triggers Discourse's docked-header hide, so
    // it's the most reliable re-assert trigger; resize handles the breakpoint.
    window.addEventListener("scroll", apply, { passive: true });
    window.addEventListener("resize", apply);
  }

  rafId = requestAnimationFrame(start);

  return () => {
    cancelAnimationFrame(rafId);
    observer?.disconnect();
    window.removeEventListener("scroll", apply);
    window.removeEventListener("resize", apply);
  };
}

/**
 * Header connector rendered in the above-site-header outlet.
 * Contains top bar (desktop), logo, nav tile, and navigation.
 * All logic lives here (no initializer) to match the discourse-header-submenus
 * pattern and prevent duplication on route transitions.
 */
export default class GbfansHeaderConnector extends Component {
  @service site;

  constructor() {
    super(...arguments);
    injectDynamicStyles();
    registerDestructor(this, watchHeaderOffset());
    registerDestructor(this, pinMobileHeaderIcons());
  }

  get isDesktop() {
    return !this.site.mobileView;
  }

  get siteUrl() {
    return gbfansSiteUrl();
  }

  get logoUrl() {
    return gbfansMainSiteUrl(
      settings.logo_url || "/GBFans-Logo-Wide-Black-BG.png",
    );
  }

  get ctaText() {
    return settings.top_bar_cta_text || "Become a Supporting Member Today!";
  }

  get ctaUrl() {
    const path = settings.top_bar_cta_url || "/supporting";
    return gbfansMainSiteUrl(path);
  }

  get brandName() {
    return settings.brand_name || "GBFans";
  }

  <template>
    {{#if this.isDesktop}}
      <div class="gbfans-top-bar" role="navigation" aria-label="Utility bar">
        <div class="gbfans-top-bar__inner">
          <p class="gbfans-top-bar__cta">
            <a href="{{this.ctaUrl}}">{{this.ctaText}}</a>
          </p>
          <div class="gbfans-top-bar__right">
            <GbfansSocialIcons @variant="gbfans-social--topbar" />
          </div>
        </div>
      </div>
    {{/if}}

    <div class="gbfans-sticky-header">
      <div class="gbfans-logo-header">
        <div class="gbfans-logo-header__inner">
          <a href="{{this.siteUrl}}" class="gbfans-logo-link" aria-label="{{this.brandName}} home">
            <img src="{{this.logoUrl}}" alt="{{this.brandName}}" class="gbfans-logo" />
          </a>
          {{#if this.isDesktop}}
            <div class="gbfans-ad-slot" role="complementary" aria-label="Advertisement"></div>
          {{/if}}
        </div>
      </div>
      <div class="gbfans-nav-tile" aria-hidden="true"></div>
    </div>

    {{#if this.isDesktop}}
      <GbfansNavDesktop />
    {{/if}}
  </template>
}
