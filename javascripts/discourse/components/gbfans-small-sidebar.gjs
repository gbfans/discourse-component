import Component from "@glimmer/component";
import { service } from "@ember/service";
import Sidebar from "discourse/components/sidebar";

/**
 * Renders Discourse's native Sidebar in a dark-themed wrapper at narrow
 * desktop widths. Uses this.site.narrowDesktopView (Discourse's built-in
 * detection) instead of CSS media queries.
 *
 * Matches the pattern from discourse-central-theme's small-screen-sidebar.gjs.
 */
export default class GbfansSmallSidebar extends Component {
  @service site;
  @service capabilities;

  get showSidebar() {
    return !this.site.mobileView && (this.site.narrowDesktopView || this.capabilities.isIpadOS);
  }

  <template>
    {{#if this.showSidebar}}
      <div class="sidebar-wrapper gbfans-small-sidebar">
        <Sidebar />
      </div>
    {{/if}}
  </template>
}
