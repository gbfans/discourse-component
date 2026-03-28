import { withPluginApi } from "discourse/lib/plugin-api";
import GbfansHeader from "../components/gbfans-header";
import GbfansFooter from "../components/gbfans-footer";

export default {
  name: "gbfans-theme",

  initialize() {
    withPluginApi((api) => {
      // Register components in Discourse outlets
      api.renderInOutlet("above-site-header", GbfansHeader);
      api.renderInOutlet("below-footer", GbfansFooter);

      const baseUrl = settings.gbfans_site_url || "https://gbfans.com";

      // Inject dynamic image URLs as CSS custom properties
      const style = document.createElement("style");
      style.id = "gbfans-dynamic-urls";
      style.textContent = `
        :root {
          --gbfans-bg-tiled-url: url("${baseUrl}/GBFans-Background-Tiled2.png");
          --gbfans-nav-tile-url: url("${baseUrl}/nav-tile.png");
          --gbfans-footer-bg-url: url("${baseUrl}/Mini-Pufts-by-Stuart-Reeves-1.png");
        }
      `;
      document.head.appendChild(style);

      // Build sidebar navigation from top-level nav_links
      const navLinks = settings.nav_links || [];
      const topLevel = navLinks.filter((l) => !l.parent);

      const sidebarLinks = topLevel.map((item) => {
        const name = item.text.toLowerCase().replace(/\s+/g, "-");
        let href = item.url;
        if (href && !href.startsWith("http") && href !== "/" && href !== "#") {
          href = `${baseUrl}${href}`;
        }
        return { name, label: item.text, href: href || baseUrl };
      });

      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const links = sidebarLinks.map((item) => {
            return class extends BaseCustomSidebarSectionLink {
              get name() {
                return `gbfans-${item.name}`;
              }
              get text() {
                return item.label;
              }
              get href() {
                return item.href;
              }
              get title() {
                return item.label;
              }
            };
          });

          return class extends BaseCustomSidebarSection {
            get name() {
              return "gbfans-navigation";
            }
            get title() {
              return settings.brand_name || "GBFans";
            }
            get links() {
              return links.map((LinkClass) => new LinkClass());
            }
            get displaySection() {
              return true;
            }
          };
        },
      );
    });
  },
};
