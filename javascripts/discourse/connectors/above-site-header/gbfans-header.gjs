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
      --gbfans-footer-bg-url: url("${gbfansMainSiteUrl("gbfans-mini-pufts.png")}");
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
  }

  get isDesktop() {
    return !this.site.mobileView;
  }

  get siteUrl() {
    return gbfansSiteUrl();
  }

  get logoUrl() {
    return gbfansMainSiteUrl(
      settings.logo_url || "/gbfans-logo-wide.png",
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
