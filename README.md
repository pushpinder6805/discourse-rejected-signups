# discourse-rejected-signups

This Discourse plugin changes the `must_approve_users` rejection flow so that staff can reject a signup now and still approve that same account later.

## What it does

- intercepts the `ReviewableUser` reject action for normal signup approvals
- archives the rejected signup in a dedicated `rejected_signups` table
- keeps the original user account in an unapproved state instead of deleting it
- adds an admin page at `/admin/plugins/rejected-signups`
- lets admins approve an archived rejected signup later

## Important behavior change

Without this plugin, rejecting a signup in the review queue normally deletes the user in many cases.

With this plugin installed, a rejected signup is archived and the account remains unapproved so it can be approved later.

## Install

1. Copy this plugin into your Discourse container plugins directory.
2. Rebuild the app.
3. Run the migration for the `rejected_signups` table.

## Admin workflow

1. Enable `must_approve_users`.
2. Reject a user from the review queue.
3. Open `Admin > Plugins > Rejected Signups`.
4. Click `Approve Now` when you want to let that user in later.

## Notes

- This plugin intentionally does not archive suspect/spam-user reviewables.
- Approval sends the normal post-approval email.
- The plugin is designed for private communities that want a non-destructive rejection workflow.
