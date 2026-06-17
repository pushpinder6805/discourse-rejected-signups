# frozen_string_literal: true

module ::Admin
  module Plugins
    class RejectedSignupsController < ::Admin::AdminController
      requires_plugin ::RejectedSignups::PLUGIN_NAME

      def index
        signups = ::RejectedSignup.includes(:user, :rejected_by, :approved_later_by).recent_first

        render json: {
          rejected_signups: signups.map { |signup| serialize_signup(signup) },
        }
      end

      def approve
        signup = ::RejectedSignup.find(params[:id])

        if signup.user.blank?
          return render_json_error("The original user account no longer exists.")
        end

        signup.approve_later!(current_user)

        if SiteSetting.must_approve_users?
          Jobs.enqueue(:critical_user_email, type: "signup_after_approval", user_id: signup.user_id)
        end

        render json: success_json.merge(rejected_signup: serialize_signup(signup.reload))
      rescue ActiveRecord::RecordInvalid => e
        render_json_error(e.record.errors.full_messages.join(", "))
      end

      private

      def serialize_signup(signup)
        user = signup.user

        {
          id: signup.id,
          reviewable_id: signup.reviewable_id,
          user_id: signup.user_id,
          username: signup.username,
          name: signup.name,
          email: signup.email,
          reject_reason: signup.reject_reason,
          rejected_at: signup.rejected_at,
          rejected_by_username: signup.rejected_by&.username,
          approved_later_at: signup.approved_later_at,
          approved_later_by_username: signup.approved_later_by&.username,
          status: signup.status,
          status_label:
            signup.status == "approved_later" ? "Approved later" : "Rejected",
          can_approve: signup.approvable?,
          user_approved: user&.approved? || false,
        }
      end
    end
  end
end
