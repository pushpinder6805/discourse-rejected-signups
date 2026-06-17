# frozen_string_literal: true

# name: discourse-rejected-signups
# about: Archive rejected signup approvals and allow staff to approve them later.
# version: 0.1
# authors: raza
# url: https://github.com/pushpinder6805/discourse-rejected-signups

enabled_site_setting :rejected_signups_enabled

after_initialize do
  module ::RejectedSignups
    PLUGIN_NAME = "discourse-rejected-signups"

    def self.archive_reviewable?(reviewable)
      SiteSetting.rejected_signups_enabled &&
        SiteSetting.must_approve_users? &&
        reviewable.is_a?(::ReviewableUser) &&
        reviewable.target.present? &&
        !reviewable.target.approved?
    end
  end

  require_relative "app/models/rejected_signup"
  require_relative "app/controllers/admin/plugins/rejected_signups_controller"

  add_admin_route "Rejected Signups", "rejected-signups"

  Discourse::Application.routes.append do
    get "/admin/plugins/rejected-signups" => "admin/plugins/rejected_signups#index"
    get "/admin/plugins/rejected-signups.json" => "admin/plugins/rejected_signups#index"
    put "/admin/plugins/rejected-signups/:id/approve" => "admin/plugins/rejected_signups#approve"
  end

  module ::RejectedSignupsReviewableUserPatch
    def perform_delete_user(performed_by, args)
      return super unless ::RejectedSignups.archive_reviewable?(self)

      self.reject_reason = args[:reject_reason]
      validate!

      ::RejectedSignup.archive_from_reviewable!(self, performed_by, args)

      if args[:send_email] && SiteSetting.must_approve_users?
        Jobs::CriticalUserEmail.new.execute(
          { type: :signup_after_reject, user_id: target.id, reject_reason: reject_reason },
        )
      end

      create_result(:success, :rejected)
    end

    def perform_delete_and_block_user(performed_by, args)
      super
    end
  end

  unless ::ReviewableUser.ancestors.include?(::RejectedSignupsReviewableUserPatch)
    ::ReviewableUser.prepend(::RejectedSignupsReviewableUserPatch)
  end
end
