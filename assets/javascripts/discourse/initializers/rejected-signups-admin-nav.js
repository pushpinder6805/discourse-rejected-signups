import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "rejected-signups-admin-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser || !currentUser.admin) {
      return;
    }

    withPluginApi((api) => {
      api.addAdminPluginConfigurationNav("discourse-rejected-signups", [
        {
          label: "admin.plugins.rejected_signups.title",
          route: "adminPlugins.show.discourse-rejected-signups",
        },
      ]);
    });
  },
};
