class Application < ApplicationRecord
  belongs_to :listing
  belongs_to :seeker, class_name: "User", inverse_of: :applications
  has_one :property, through: :listing
  has_many :visits, -> { order(:scheduled_at) }, dependent: :destroy, inverse_of: :application

  enum :status, {
    pending: "pending",
    shortlisted: "shortlisted",
    accepted: "accepted",
    rejected: "rejected",
    withdrawn: "withdrawn"
  }, validate: true

  # Which states an application can move to from each state. Accepting goes through #accept.
  TRANSITIONS = {
    "pending" => %w[shortlisted accepted rejected withdrawn],
    "shortlisted" => %w[accepted rejected withdrawn],
    "accepted" => [],
    "rejected" => [],
    "withdrawn" => []
  }.freeze

  validates :message, presence: true
  validates :move_in_date, presence: true
  validates :stay_duration_months, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :seeker_id, uniqueness: { scope: :listing_id, message: "has already applied to this listing" }
  validates :listing_id, uniqueness: { conditions: -> { where(status: :accepted) },
                                       message: "already has an accepted application" }, if: :accepted?

  validate :seeker_is_not_the_host
  validate :listing_is_published, on: :create
  validate :stay_covers_minimum_stay, if: -> { new_record? || will_save_change_to_stay_duration_months? }
  validate :status_transition_allowed, on: :update

  scope :awaiting_answer, -> { where(status: [ :pending, :shortlisted ]) }
  scope :decided, -> { where(status: [ :accepted, :rejected, :withdrawn ]) }
  scope :newest_first, -> { order(created_at: :desc) }

  def withdrawable?
    pending? || shortlisted?
  end

  # Only the seeker who wrote the application can pull it back, and only while it is still open.
  def withdraw_by(user)
    if user.blank? || user.id != seeker_id
      errors.add(:base, "Only the seeker who sent the application can withdraw it")
      return false
    end

    update(status: :withdrawn)
  end

  # Accepting an applicant is a single decision: this application becomes accepted, every other open
  # application on the listing is rejected and the listing moves to reserved. If any step fails the
  # transaction is rolled back and nothing changes. Returns the applications rejected along the way.
  def accept
    rejected = []

    transaction do
      unless listing.published?
        errors.add(:base, "This listing is #{listing.status} and can no longer accept an applicant")
        raise ActiveRecord::Rollback
      end

      update!(status: :accepted)
      rejected = listing.applications.where.not(id: id).awaiting_answer.to_a
      rejected.each { |other| other.update!(status: :rejected) }
      listing.update!(status: :reserved)
    end

    errors.empty? ? rejected : false
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    restore_attributes
    listing.reload
    errors.add(:base, "The applicant could not be accepted: #{e.message}")
    false
  end

  def to_s
    "#{seeker.name} → #{listing.title}"
  end

  private

  def seeker_is_not_the_host
    return if listing.blank? || seeker.blank?

    if listing.property.host_id == seeker_id
      errors.add(:seeker, "can't apply to their own listing")
    end
  end

  def listing_is_published
    return if listing.blank?

    errors.add(:listing, "is not open for applications") unless listing.published?
  end

  def status_transition_allowed
    return unless status_changed?

    errors.add(:status, "can't change from #{status_was} to #{status}") unless TRANSITIONS.fetch(status_was, []).include?(status)
  end

  def stay_covers_minimum_stay
    return if listing.blank? || stay_duration_months.blank?

    if stay_duration_months < listing.minimum_stay_months
      errors.add(:stay_duration_months, "must be at least the listing's minimum stay (#{listing.minimum_stay_months} months)")
    end
  end
end
