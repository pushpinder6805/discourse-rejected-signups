import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class AdminPluginsRejectedSignupsRoute extends DiscourseRoute {
  model() {
    return ajax("/admin/plugins/rejected-signups.json");
  }
}
