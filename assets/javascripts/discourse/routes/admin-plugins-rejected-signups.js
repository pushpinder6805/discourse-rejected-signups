import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class AdminPluginsRejectedSignupsRoute extends DiscourseRoute {
  model() {
    return ajax("/admin/plugins/rejected-signups.json");
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.setSignups(model.rejected_signups || []);
  }
}
