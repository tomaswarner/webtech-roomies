class Review < ApplicationRecord
  belongs_to :property
  belongs_to :visit
  belongs_to :seeker, class_name: "User", inverse_of: :reviews

  before_validation :take_property_and_seeker_from_visit

  validates :rating, numericality: { only_integer: true, in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10 }
  validates :visit_id, uniqueness: { message: "has already been reviewed" }

  validate :visit_is_completed
  validate :seeker_is_not_the_host

  scope :newest_first, -> { order(created_at: :desc) }

  private

  def take_property_and_seeker_from_visit
    return if visit.blank?

    self.property ||= visit.application.listing.property
    self.seeker ||= visit.application.seeker
  end

  def visit_is_completed
    return if visit.blank?

    errors.add(:visit, "must be completed before it can be reviewed") unless visit.completed?
  end

  def seeker_is_not_the_host
    return if property.blank? || seeker_id.blank?

    errors.add(:seeker, "can't review their own property") if property.host_id == seeker_id
  end
end
