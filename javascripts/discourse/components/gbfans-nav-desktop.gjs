import Component from "@glimmer/component";

const DEFAULT_GBFANS_SITE_URL = "https://www.gbfans.com";

function gbfansSiteUrl() {
  const rawUrl = settings.gbfans_site_url || DEFAULT_GBFANS_SITE_URL;
  return String(rawUrl).trim().replace(/\/+$/, "") || DEFAULT_GBFANS_SITE_URL;
}

/** Desktop navigation bar with CSS-only hover dropdowns. */
export default class GbfansNavDesktop extends Component {
  get siteUrl() {
    return gbfansSiteUrl();
  }

  /** Resolve a URL: external URLs pass through, "/" stays as-is, others get site URL prefix. */
  _resolveUrl(url) {
    if (!url || url === "#") return null;
    if (url.startsWith("http")) return url;
    if (url === "/") return "/";
    return `${this.siteUrl}${url}`;
  }

  /** Build a tree from the flat nav_links setting. */
  get navTree() {
    const links = settings.nav_links || [];
    const topLevel = links.filter((l) => !l.parent);

    return topLevel.map((item) => ({
      text: item.text,
      url: this._resolveUrl(item.url),
      target: item.target || "_self",
      rel: item.target === "_blank" ? "noreferrer" : "",
      isForum: item.url === "/",
      children: links
        .filter((l) => l.parent === item.text)
        .map((child) => ({
          text: child.text,
          url: this._resolveUrl(child.url),
          target: child.target || "_self",
          rel: child.target === "_blank" ? "noreferrer" : "",
          isHeader: !child.url || child.url === "#",
        })),
    }));
  }

  <template>
    <nav class="gbfans-main-nav" aria-label="Primary">
      <ul class="gbfans-nav-list" role="menubar">
        {{#each this.navTree as |item|}}
          <li
            class="gbfans-nav-item{{if item.children.length ' has-dropdown'}}{{if item.isForum ' gbfans-nav-item--forum'}}"
            role="none"
          >
            <a
              href="{{item.url}}"
              class="gbfans-nav-item__link{{if item.isForum ' gbfans-nav-item__link--forum'}}"
              role="menuitem"
              target="{{item.target}}"
              rel="{{item.rel}}"
            >
              {{item.text}}
              {{#if item.children.length}}
                <span class="gbfans-nav-arrow" aria-hidden="true">&#9662;</span>
              {{/if}}
            </a>
            {{#if item.children.length}}
              <ul class="gbfans-nav-dropdown" role="menu">
                {{#each item.children as |child|}}
                  <li role="none">
                    {{#if child.isHeader}}
                      <span class="gbfans-nav-dropdown__header">{{child.text}}</span>
                    {{else}}
                      <a
                        href="{{child.url}}"
                        class="gbfans-nav-dropdown__link"
                        role="menuitem"
                        target="{{child.target}}"
                        rel="{{child.rel}}"
                      >
                        {{child.text}}
                      </a>
                    {{/if}}
                  </li>
                {{/each}}
              </ul>
            {{/if}}
          </li>
        {{/each}}
      </ul>
    </nav>
  </template>
}
