class Report < ApplicationRecord
  REASONS = %w[fraudulent misleading offensive other].freeze

  belongs_to :listing
  belongs_to :reporter, class_name: "User", inverse_of: :reports
  belongs_to :resolved_by, class_name: "User", optional: true, inverse_of: :resolved_reports

  enum :status, { pending: "pending", resolved: "resolved", dismissed: "dismissed" }, validate: true

  validates :reason, presence: true, inclusion: { in: REASONS }
  validates :resolved_by, presence: true, unless: :pending?

  validate :resolved_by_a_moderator

  scope :newest_first, -> { order(created_at: :desc) }

  private

  def resolved_by_a_moderator
    return if resolved_by.blank?

    errors.add(:resolved_by, "must be a moderator") unless resolved_by.moderator?
  end
end
