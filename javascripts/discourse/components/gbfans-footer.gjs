import Component from "@glimmer/component";
import GbfansSocialIcons from "./gbfans-social-icons";

/** Site footer with branding, description, search, and copyright. */
export default class GbfansFooter extends Component {
  get siteUrl() {
    return settings.gbfans_site_url || "https://gbfans.com";
  }

  get footerLogoUrl() {
    return `${this.siteUrl}${settings.footer_logo_url || "/GBFans-Square-Logo-White-Text.png"}`;
  }

  get brandName() {
    return settings.brand_name || "GBFans";
  }

  get description() {
    return settings.footer_description || "";
  }

  get joinUrl() {
    const path = settings.footer_join_url || "/sign-up/";
    return `${this.siteUrl}${path}`;
  }

  get currentYear() {
    return new Date().getFullYear();
  }

  <template>
    <footer class="gbfans-footer" role="contentinfo">
      <div class="gbfans-footer-branding">
        <div class="gbfans-footer-branding__inner">
          <div>
            <img src="{{this.footerLogoUrl}}" alt="{{this.brandName}}" class="gbfans-footer-logo" />
            <GbfansSocialIcons @variant="gbfans-social--footer" />
          </div>

          <div class="gbfans-footer-description">
            {{this.description}}
            <strong>
              <a href="{{this.joinUrl}}" class="gbfans-footer-join">JOIN US!</a>
            </strong>
          </div>

          <div>
            <span class="gbfans-footer-search-heading">Search Something</span>
            <form class="gbfans-footer-search" role="search" action="{{this.siteUrl}}/" method="get">
              <label for="gbfans-footer-search" class="sr-only">Search {{this.brandName}} content</label>
              <input id="gbfans-footer-search" name="s" type="search" placeholder="Type something and Enter" class="gbfans-footer-search__input" />
              <button type="submit" aria-label="Search" class="gbfans-footer-search__button">&#128269;</button>
            </form>
          </div>
        </div>
      </div>

      <div class="gbfans-footer-copyright">
        <div class="gbfans-footer-copyright__inner">
          &copy; 2000 - {{this.currentYear}} {{this.brandName}} LLC. All rights reserved. Created by AJ Quick
          <br />
          &ldquo;GBFans.com&rdquo; is a registered Trademark of {{this.brandName}} LLC.
          <br />
          &ldquo;Ghostbusters&rdquo; and &ldquo;Ghost-Design&rdquo; are
          registered Trademarks of Columbia Pictures Industries Inc.
        </div>
      </div>
    </footer>
  </template>
}
