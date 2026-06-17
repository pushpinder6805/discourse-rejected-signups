# frozen_string_literal: true

class ::RejectedSignup < ActiveRecord::Base
  self.table_name = "rejected_signups"

  belongs_to :user, optional: true
  belongs_to :reviewable, class_name: "Reviewable", optional: true
  belongs_to :rejected_by, class_name: "User", optional: true
  belongs_to :approved_later_by, class_name: "User", optional: true

  validates :reviewable_id, presence: true, uniqueness: true
  validates :username, presence: true

  scope :recent_first, -> { order(rejected_at: :desc, created_at: :desc) }

  def self.archive_from_reviewable!(reviewable, performed_by, args = {})
    user = reviewable.target || reviewable.try(:target_user)

    record = find_or_initialize_by(reviewable_id: reviewable.id)
    record.user = user
    record.reviewable = reviewable
    record.rejected_by = performed_by
    record.username = user&.username || reviewable.payload&.dig("username")
    record.email = user&.email || reviewable.payload&.dig("email")
    record.name = user&.name
    record.reject_reason = args[:reject_reason].presence
    record.payload = reviewable.payload || {}
    record.rejected_at ||= Time.zone.now
    record.save!
    record
  end

  def status
    return "approved_later" if approved_later_at.present? || user&.approved?
    "rejected"
  end

  def approvable?
    user.present? && !user.approved?
  end

  def approve_later!(approved_by)
    raise Discourse::InvalidParameters.new(:user_id) if user.blank?

    ::ReviewableUser.set_approved_fields!(user, approved_by)
    user.save!

    update!(
      approved_later_at: Time.zone.now,
      approved_later_by: approved_by,
    )
  end
end
