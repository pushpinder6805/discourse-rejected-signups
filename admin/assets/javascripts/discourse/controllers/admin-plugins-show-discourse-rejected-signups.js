import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class DiscourseRejectedSignupsController extends Controller {
  @tracked signups = [];

  @action
  async approve(signup) {
    this.signups = this.signups.map((item) =>
      item.id === signup.id ? { ...item, isApproving: true } : item
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
    } finally {
      this.signups = this.signups.map((item) =>
        item.id === signup.id ? { ...item, isApproving: false } : item
      );
    }
  }
}
