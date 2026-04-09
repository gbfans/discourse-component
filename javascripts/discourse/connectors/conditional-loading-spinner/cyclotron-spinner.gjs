import Component from "@glimmer/component";

/**
 * Replaces Discourse's default loading spinner with the GBFans cyclotron
 * animation. Controlled by the enable_cyclotron_spinner theme setting.
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
        <div class="spinner"></div>
      {{/if}}
    {{else}}
      {{yield}}
    {{/if}}
  </template>
}
