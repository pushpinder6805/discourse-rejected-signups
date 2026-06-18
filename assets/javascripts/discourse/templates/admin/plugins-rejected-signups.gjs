import { fn } from "@ember/helper";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/ui-kit/d-page-subheader";
import { i18n } from "discourse-i18n";

export default <template>
  <div class="rejected-signups admin-detail">
    <DPageSubheader
      @titleLabel={{i18n "admin.plugins.rejected_signups.title"}}
      @descriptionLabel={{i18n "admin.plugins.rejected_signups.subtitle"}}
    />

    {{#if @controller.signups.length}}
      <table class="table">
        <thead>
          <tr>
            <th>{{i18n "admin.plugins.rejected_signups.columns.username"}}</th>
            <th>{{i18n "admin.plugins.rejected_signups.columns.email"}}</th>
            <th>{{i18n "admin.plugins.rejected_signups.columns.rejected_at"}}</th>
            <th>{{i18n "admin.plugins.rejected_signups.columns.rejected_by"}}</th>
            <th>{{i18n "admin.plugins.rejected_signups.columns.reason"}}</th>
            <th>{{i18n "admin.plugins.rejected_signups.columns.status"}}</th>
            <th>{{i18n "admin.plugins.rejected_signups.columns.actions"}}</th>
          </tr>
        </thead>

        <tbody>
          {{#each @controller.signups as |signup|}}
            <tr>
              <td>{{signup.username}}</td>
              <td>{{signup.email}}</td>
              <td>{{signup.rejected_at}}</td>
              <td>{{signup.rejected_by_username}}</td>
              <td>{{if signup.reject_reason signup.reject_reason "-"}}</td>
              <td>{{signup.status_label}}</td>
              <td>
                {{#if signup.can_approve}}
                  <DButton
                    @action={{fn @controller.approve signup}}
                    @disabled={{signup.isApproving}}
                    @label={{if
                      signup.isApproving
                      "admin.plugins.rejected_signups.approving"
                      "admin.plugins.rejected_signups.approve"
                    }}
                    class="btn-primary"
                  />
                {{else}}
                  <span>{{signup.status_label}}</span>
                {{/if}}
              </td>
            </tr>
          {{/each}}
        </tbody>
      </table>
    {{else}}
      <p>{{i18n "admin.plugins.rejected_signups.empty"}}</p>
    {{/if}}
  </div>
</template>
