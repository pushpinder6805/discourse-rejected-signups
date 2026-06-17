import { registerAdminPluginConfigNav } from "discourse/lib/admin-plugin-config-nav";

export default {
  name: "rejected-signups-admin-nav",

  initialize() {
    registerAdminPluginConfigNav("discourse-rejected-signups", [
      {
        route: "adminPlugins.show.discourse-rejected-signups",
        label: "admin.plugins.rejected_signups.title",
      },
    ]);
  },
};
