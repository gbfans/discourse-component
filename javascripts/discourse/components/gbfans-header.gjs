import Component from "@glimmer/component";
import { service } from "@ember/service";
import GbfansNavDesktop from "./gbfans-nav-desktop";
import GbfansSocialIcons from "./gbfans-social-icons";

/**
 * Module-level singleton guard. Tracks how many GbfansHeader instances
 * are currently mounted. Only the first instance renders content;
 * subsequent duplicates (from outlet re-renders) render nothing.
 */
let mountedCount = 0;

/** Header component: top bar (desktop), logo, nav tile, and navigation (desktop). */
export default class GbfansHeader extends Component {
  @service site;

  _isMounted = false;

  constructor() {
    super(...arguments);
    mountedCount++;
    this._isMounted = true;
  }

  willDestroy() {
    super.willDestroy(...arguments);
    if (this._isMounted) {
      mountedCount--;
      this._isMounted = false;
    }
  }

  get isDuplicate() {
    return mountedCount > 1 && !this._isFirst;
  }

  _isFirst = (() => {
    return mountedCount <= 1;
  })();

  get isDesktop() {
    return !this.site.mobileView;
  }

  get siteUrl() {
    return settings.gbfans_site_url || "https://gbfans.com";
  }

  get logoUrl() {
    return `${this.siteUrl}${settings.logo_url || "/GBFans-Logo-Wide-Black-BG.png"}`;
  }

  get ctaText() {
    return settings.top_bar_cta_text || "Become a Supporting Member Today!";
  }

  get ctaUrl() {
    const path = settings.top_bar_cta_url || "/supporting";
    return `${this.siteUrl}${path}`;
  }

  get brandName() {
    return settings.brand_name || "GBFans";
  }

  <template>
    {{#unless this.isDuplicate}}
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
    {{/unless}}
  </template>
}
