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

    def self.log(message)
      Rails.logger.warn("[discourse-rejected-signups] #{message}")
    end

    def self.archive_reviewable?(reviewable, action_id = nil)
      SiteSetting.rejected_signups_enabled &&
        SiteSetting.must_approve_users? &&
        reviewable.status.to_s == "pending" &&
        reviewable.target.present? &&
        reviewable.target_type == "User" &&
        !reviewable.target.approved? &&
        action_id.to_s == "delete_user"
    end

    def self.archive_user_destroy?(user, opts = {})
      SiteSetting.rejected_signups_enabled &&
        SiteSetting.must_approve_users? &&
        user.present? &&
        !user.approved? &&
        opts[:reviewable_id].present? &&
        !opts[:block_email] &&
        !opts[:block_ip]
    end
  end

  require_relative "app/models/rejected_signup"
  require_relative "app/controllers/admin/plugins/rejected_signups_controller"

  add_admin_route "admin.plugins.rejected_signups.title", "rejected-signups"

  Discourse::Application.routes.append do
    get "/admin/plugins/rejected-signups" => "admin/plugins#index", constraints: StaffConstraint.new
    get "/admin/plugins/rejected-signups.json" => "admin/plugins/rejected_signups#index"
    put "/admin/plugins/rejected-signups/:id/approve" => "admin/plugins/rejected_signups#approve"
  end

  module ::RejectedSignupsReviewablePerformPatch
    def perform(performed_by, action_id, args = nil)
      if target_type == "User"
        ::RejectedSignups.log(
          "Reviewable#perform type=#{self.class.name} id=#{id} action=#{action_id} " \
            "status=#{status} target_id=#{target_id} approved=#{target&.approved?}",
        )
      end

      return super unless ::RejectedSignups.archive_reviewable?(self, action_id)

      args ||= {}
      guardian = args[:guardian] || Guardian.new(performed_by)
      perform_method = :perform_archive_rejected_signup

      validate_action!(guardian, action_id, perform_method, args)

      affected_candidate_ids = pending_reviewable_ids_for_target_user
      result = nil
      update_count = false

      self.class.transaction do
        increment_version!(args[:version])
        result = public_send(perform_method, performed_by, args)

        raise ActiveRecord::Rollback unless result.success?

        update_count = transition_to(result.transition_to, performed_by) if result.transition_to
        update_flag_stats(**result.update_flag_stats) if result.update_flag_stats
        recalculate_score if result.recalculate_score
      end

      result.after_commit.call if result&.after_commit

      if result&.success? && affected_candidate_ids.present?
        result.affected_reviewable_ids |= resolved_reviewable_ids(affected_candidate_ids)
      end

      unless status.to_s == "pending"
        if update_count || result.remove_reviewable_ids.present?
          Jobs.enqueue(
            :notify_reviewable,
            reviewable_id: id,
            performing_username: performed_by.username,
            updated_reviewable_ids: result.remove_reviewable_ids,
          )
        else
          notify_users(result, guardian)
        end
      end

      result
    end

    def perform_archive_rejected_signup(performed_by, args)
      self.reject_reason = args[:reject_reason]
      validate!

      ::RejectedSignup.archive_from_reviewable!(self, performed_by, args)
      ::RejectedSignups.log(
        "Archived reviewable id=#{id} target_id=#{target&.id} username=#{target&.username || payload&.dig("username")}",
      )

      if args[:send_email] && SiteSetting.must_approve_users?
        Jobs::CriticalUserEmail.new.execute(
          { type: :signup_after_reject, user_id: target.id, reject_reason: reject_reason },
        )
      end

      create_result(:success, :rejected)
    end
  end

  module ::RejectedSignupsReviewableUserPatch
    def perform_delete_user(performed_by, args)
      return super unless ::RejectedSignups.archive_reviewable?(self, :delete_user)

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

    def perform_delete_user_block(performed_by, args)
      super
    end
  end

  module ::RejectedSignupsUserDestroyerPatch
    def destroy(user, opts = {})
      ::RejectedSignups.log(
        "UserDestroyer#destroy user_id=#{user&.id} username=#{user&.username} " \
          "reviewable_id=#{opts[:reviewable_id]} block_email=#{opts[:block_email]} block_ip=#{opts[:block_ip]}",
      )

      if ::RejectedSignups.archive_user_destroy?(user, opts)
        reviewable = ::Reviewable.find_by(id: opts[:reviewable_id])

        if reviewable.present? &&
             (reviewable.target == user || reviewable.target_id == user.id ||
               reviewable.target_created_by_id == user.id)
          ::RejectedSignup.archive_from_reviewable!(
            reviewable,
            @actor,
            { reject_reason: reviewable.reject_reason },
          )

          ::RejectedSignups.log(
            "Archived from UserDestroyer reviewable_id=#{reviewable.id} user_id=#{user.id} username=#{user.username}",
          )

          return user
        end
      end

      super
    end
  end

  unless ::ReviewableUser.ancestors.include?(::RejectedSignupsReviewableUserPatch)
    ::ReviewableUser.prepend(::RejectedSignupsReviewableUserPatch)
  end

  unless ::Reviewable.ancestors.include?(::RejectedSignupsReviewablePerformPatch)
    ::Reviewable.prepend(::RejectedSignupsReviewablePerformPatch)
  end

  unless ::UserDestroyer.ancestors.include?(::RejectedSignupsUserDestroyerPatch)
    ::UserDestroyer.prepend(::RejectedSignupsUserDestroyerPatch)
  end
end
