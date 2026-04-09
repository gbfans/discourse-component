import Component from "@glimmer/component";
import LoadingSpinner from "discourse/components/loading-spinner";

/**
 * Replaces Discourse's default loading spinner with the GBFans cyclotron
 * animation. Controlled by the enable_cyclotron_spinner theme setting.
 * When disabled, falls back to Discourse's native LoadingSpinner which
 * respects the site-wide loading_indicator setting (spinner or dots).
 */
export default class CyclotronSpinner extends Component {
  <template>
    {{#if @outletArgs.condition}}
      {{#if settings.enable_cyclotron_spinner}}
        <div class="gbfans-cyclotron-loader">
          <div class="gbfans-cyclotron-spinner" role="status" aria-label="Loading">
            <div class="gbfans-cyclotron-spinner__rotor"></div>
            <span class="sr-only">Loading…</span>
          </div>
        </div>
      {{else}}
        <LoadingSpinner />
      {{/if}}
    {{else}}
      {{yield}}
    {{/if}}
  </template>
}
