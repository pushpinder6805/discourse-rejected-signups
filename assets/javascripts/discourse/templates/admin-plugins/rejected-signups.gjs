import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import { i18n } from "discourse-i18n";

<template>
  <section class="admin-detail">
    <div class="admin-container">
      <h1>{{i18n "admin.plugins.rejected_signups.title"}}</h1>
      <p>{{i18n "admin.plugins.rejected_signups.subtitle"}}</p>

      {{#if this.signups.length}}
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
            {{#each this.signups as |signup|}}
              <tr>
                <td>{{signup.username}}</td>
                <td>{{signup.email}}</td>
                <td>{{signup.rejected_at}}</td>
                <td>{{signup.rejected_by_username}}</td>
                <td>{{if signup.reject_reason signup.reject_reason "-"}}</td>
                <td>{{signup.status_label}}</td>
                <td>
                  {{#if signup.can_approve}}
                    <button
                      class="btn btn-primary"
                      type="button"
                      disabled={{signup.is_approving}}
                      {{on "click" (fn this.approve signup)}}
                    >
                      {{#if signup.is_approving}}
                        {{i18n "admin.plugins.rejected_signups.approving"}}
                      {{else}}
                        {{i18n "admin.plugins.rejected_signups.approve"}}
                      {{/if}}
                    </button>
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
  </section>
</template>
