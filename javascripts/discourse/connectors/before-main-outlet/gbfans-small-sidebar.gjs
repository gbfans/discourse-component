/* eslint-disable ember/no-classic-components */
import Component from "@ember/component";
import { tagName } from "@ember-decorators/component";
import GbfansSmallSidebar from "../../components/gbfans-small-sidebar";

/** Connector that renders the small-screen sidebar in the before-main-outlet. */
@tagName("")
export default class GbfansSmallSidebarConnector extends Component {
  <template><GbfansSmallSidebar /></template>
}
