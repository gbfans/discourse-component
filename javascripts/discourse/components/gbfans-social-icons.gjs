import Component from "@glimmer/component";
import icon from "discourse/helpers/d-icon";

/** Shared social icon links. Renders from settings.social_links using Discourse icons. */
export default class GbfansSocialIcons extends Component {
  get links() {
    return settings.social_links || [];
  }

  <template>
    <ul class="gbfans-social {{@variant}}" aria-label="Social links">
      {{#each this.links as |link|}}
        <li>
          <a
            href="{{link.url}}"
            target="_blank"
            rel="noreferrer"
            aria-label="{{link.name}}"
            title="{{link.name}}"
            class="gbfans-social__link"
          >
            {{icon link.icon}}
          </a>
        </li>
      {{/each}}
    </ul>
  </template>
}
