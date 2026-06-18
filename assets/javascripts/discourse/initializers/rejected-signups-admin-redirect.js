function archivePathFor(pathname) {
  const pluginPath = "/admin/plugins/discourse-rejected-signups";
  const pluginPathIndex = pathname.indexOf(pluginPath);
  const basePath = pluginPathIndex > 0 ? pathname.slice(0, pluginPathIndex) : "";

  return `${basePath}/admin/plugins/rejected-signups`;
}

function isDefaultPluginPage(pathname) {
  const normalizedPath = pathname.replace(/\/+$/, "");

  return (
    normalizedPath.endsWith("/admin/plugins/discourse-rejected-signups") ||
    normalizedPath.endsWith("/admin/plugins/discourse-rejected-signups/settings")
  );
}

function redirectToArchivePage() {
  if (!isDefaultPluginPage(window.location.pathname)) {
    return;
  }

  window.location.replace(archivePathFor(window.location.pathname));
}

export default {
  name: "rejected-signups-admin-redirect",

  initialize(container) {
    redirectToArchivePage();

    const router = container.lookup("service:router");
    router?.on?.("routeDidChange", redirectToArchivePage);
  },
};
