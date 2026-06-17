import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class AdminPluginsRejectedSignupsController extends Controller {
  @tracked signups = [];

  setSignups(signups) {
    this.signups = signups;
  }

  @action
  async approve(signup) {
    this.signups = this.signups.map((item) =>
      item.id === signup.id ? { ...item, is_approving: true } : item
    );

    try {
      const response = await ajax(`/admin/plugins/rejected-signups/${signup.id}/approve`, {
        type: "PUT",
      });

      this.signups = this.signups.map((item) =>
        item.id === signup.id ? response.rejected_signup : item
      );
    } catch (error) {
      popupAjaxError(error);
      this.signups = this.signups.map((item) =>
        item.id === signup.id ? { ...item, is_approving: false } : item
      );
    } finally {
      this.signups = this.signups.map((item) =>
        item.id === signup.id ? { ...item, is_approving: false } : item
      );
    }
  }
}
