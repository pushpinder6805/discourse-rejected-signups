import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class AdminPluginsShowDiscourseRejectedSignupsRoute extends DiscourseRoute {
  async model() {
    return ajax("/admin/plugins/rejected-signups.json");
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.setSignups(model.rejected_signups || []);
  }
}
