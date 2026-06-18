import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class DiscourseRejectedSignupsArchiveRoute extends DiscourseRoute {
  model() {
    return ajax("/admin/plugins/rejected-signups.json");
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.signups = model.rejected_signups || [];
  }
}
