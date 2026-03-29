import Component from "@glimmer/component";

/** Mobile-only header: logo and nav tile. */
export default class GbfansHeaderMobile extends Component {
  get siteUrl() {
    return settings.gbfans_site_url || "https://gbfans.com";
  }

  get logoUrl() {
    return `${this.siteUrl}${settings.logo_url || "/GBFans-Logo-Wide-Black-BG.png"}`;
  }

  get brandName() {
    return settings.brand_name || "GBFans";
  }

  <template>
    <div class="gbfans-sticky-header">
      <div class="gbfans-logo-header">
        <div class="gbfans-logo-header__inner">
          <a href="{{this.siteUrl}}" class="gbfans-logo-link" aria-label="{{this.brandName}} home">
            <img src="{{this.logoUrl}}" alt="{{this.brandName}}" class="gbfans-logo" />
          </a>
        </div>
      </div>
      <div class="gbfans-nav-tile" aria-hidden="true"></div>
    </div>
  </template>
}
