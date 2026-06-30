import Component from "@glimmer/component";
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
