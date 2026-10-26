class Visit < ApplicationRecord
  belongs_to :application, inverse_of: :visits
  has_one :listing, through: :application
  has_one :review, dependent: :restrict_with_error

  enum :status, {
    proposed: "proposed",
    confirmed: "confirmed",
    cancelled: "cancelled",
    completed: "completed"
  }, validate: true

  # Rescheduling sends a confirmed visit back to proposed so the seeker confirms the new time.
  TRANSITIONS = {
    "proposed" => %w[confirmed cancelled],
    "confirmed" => %w[proposed completed cancelled],
    "cancelled" => [],
    "completed" => []
  }.freeze

  validates :scheduled_at, presence: true

  validate :scheduled_after_application
  validate :application_is_shortlisted, on: :create
  validate :completed_visit_already_happened
  validate :not_scheduled_in_the_past
  validate :status_transition_allowed, on: :update

  scope :upcoming, -> { where(status: [ :proposed, :confirmed ]).where(scheduled_at: Time.current..).order(:scheduled_at) }
  scope :past, -> { where(scheduled_at: ...Time.current) }
  scope :chronological, -> { order(:scheduled_at) }

  def open?
    proposed? || confirmed?
  end

  def reschedule(new_time)
    update(scheduled_at: new_time, status: :proposed)
  end

  private

  def not_scheduled_in_the_past
    return if scheduled_at.blank? || !open?
    return unless new_record? || will_save_change_to_scheduled_at?

    errors.add(:scheduled_at, "can't be in the past") if scheduled_at < Time.current
  end

  def status_transition_allowed
    return unless status_changed?

    errors.add(:status, "can't change from #{status_was} to #{status}") unless TRANSITIONS.fetch(status_was, []).include?(status)
  end

  def scheduled_after_application
    return if scheduled_at.blank? || application.blank? || application.created_at.blank?

    if scheduled_at <= application.created_at
      errors.add(:scheduled_at, "must be after the application was sent")
    end
  end

  # Nobody visits a house they have not been shortlisted for.
  def application_is_shortlisted
    return if application.blank?

    errors.add(:application, "must be shortlisted before a visit is proposed") unless application.shortlisted?
  end

  def completed_visit_already_happened
    return unless completed? && scheduled_at.present?

    errors.add(:status, "can't be completed before the visit takes place") if scheduled_at > Time.current
  end
end
