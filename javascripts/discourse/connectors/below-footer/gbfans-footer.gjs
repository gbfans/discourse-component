import Component from "@glimmer/component";
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
 * Footer connector rendered in the below-footer outlet.
 * Contains branding, description, search, and copyright.
 * All logic lives here (no initializer) to match the discourse-header-submenus
 * pattern and prevent duplication on route transitions.
 */
export default class GbfansFooterConnector extends Component {
  get siteUrl() {
    return gbfansSiteUrl();
  }

  get footerLogoUrl() {
    return gbfansMainSiteUrl(
      settings.footer_logo_url || "/GBFans-Square-Logo-White-Text.png",
    );
  }

  get brandName() {
    return settings.brand_name || "GBFans";
  }

  get description() {
    return settings.footer_description || "";
  }

  get joinUrl() {
    const path = settings.footer_join_url || "/sign-up/";
    return gbfansMainSiteUrl(path);
  }

  /** Footer legal links (Privacy Policy, Terms of Service, DMCA) with URLs resolved against the main site. */
  get legalLinks() {
    return (settings.footer_legal_links || []).map((link) => ({
      text: link.text,
      url: gbfansMainSiteUrl(link.url),
    }));
  }

  get searchUrl() {
    return gbfansMainSiteUrl("/search");
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
            <form class="gbfans-footer-search" role="search" action="{{this.searchUrl}}" method="get">
              <label for="gbfans-footer-search" class="sr-only">Search {{this.brandName}} content</label>
              <input id="gbfans-footer-search" name="q" type="search" placeholder="Type something and Enter" class="gbfans-footer-search__input" />
              <button type="submit" aria-label="Search" class="gbfans-footer-search__button">&#128269;</button>
            </form>
          </div>
        </div>
      </div>

      <div class="gbfans-footer-copyright">
        <div class="gbfans-footer-copyright__inner">
          &copy; 2000 - {{this.currentYear}} {{this.brandName}} LLC. All rights reserved. Created by AJ Quick
          {{#if this.legalLinks.length}}
            <nav class="gbfans-footer-legal" aria-label="Legal links">
              {{#each this.legalLinks as |link|}}
                <a href="{{link.url}}" class="gbfans-footer-legal__link">{{link.text}}</a>
              {{/each}}
            </nav>
          {{else}}
            <br />
          {{/if}}
          &ldquo;GBFans.com&rdquo; is a registered Trademark of {{this.brandName}} LLC.
          <br />
          &ldquo;Ghostbusters&rdquo; and &ldquo;Ghost-Design&rdquo; are
          registered Trademarks of Columbia Pictures Industries Inc.
        </div>
      </div>
    </footer>
  </template>
}
