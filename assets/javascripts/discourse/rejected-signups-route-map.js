export default {
  resource: "admin.adminPlugins",
  path: "/plugins",

  map() {
    this.route("rejected-signups", { path: "/rejected-signups" });
  },
};
