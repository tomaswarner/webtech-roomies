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

  validates :message, presence: true
  validates :move_in_date, presence: true
  validates :stay_duration_months, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :seeker_id, uniqueness: { scope: :listing_id, message: "has already applied to this listing" }
  validates :listing_id, uniqueness: { conditions: -> { where(status: :accepted) },
                                       message: "already has an accepted application" }, if: :accepted?

  validate :seeker_is_not_the_host
  validate :listing_is_published, on: :create
  validate :stay_covers_minimum_stay

  scope :awaiting_answer, -> { where(status: [ :pending, :shortlisted ]) }
  scope :decided, -> { where(status: [ :accepted, :rejected, :withdrawn ]) }
  scope :newest_first, -> { order(created_at: :desc) }

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

  def stay_covers_minimum_stay
    return if listing.blank? || stay_duration_months.blank?

    if stay_duration_months < listing.minimum_stay_months
      errors.add(:stay_duration_months, "must be at least the listing's minimum stay (#{listing.minimum_stay_months} months)")
    end
  end
end
