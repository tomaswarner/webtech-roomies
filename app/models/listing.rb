class Listing < ApplicationRecord
  belongs_to :property
  has_one :neighborhood, through: :property
  has_one :host, through: :property
  has_many :photos, -> { order(:position) }, class_name: "ListingPhoto", dependent: :destroy, inverse_of: :listing
  has_many :applications, dependent: :restrict_with_error
  has_many :saved_listings, dependent: :destroy
  has_many :savers, through: :saved_listings, source: :seeker
  has_many :reports, dependent: :destroy

  enum :status, {
    draft: "draft",
    published: "published",
    reserved: "reserved",
    rented: "rented",
    withdrawn: "withdrawn"
  }, validate: true

  validates :title, presence: true, length: { maximum: 120 }
  validates :monthly_rent, numericality: { greater_than: 0 }
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_stay_months, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :available_on, presence: true

  validate :available_on_not_in_the_past

  scope :visible, -> { where(status: [ :published, :reserved, :rented ]) }
  scope :available_from, ->(date) { where(available_on: ..date) }
  scope :under_rent, ->(amount) { where(monthly_rent: ..amount) }
  scope :in_neighborhood, ->(neighborhood) { joins(:property).where(properties: { neighborhood_id: neighborhood }) }
  scope :with_amenities, ->(amenity_ids) {
    ids = Array(amenity_ids).compact_blank.map(&:to_i).uniq
    next all if ids.empty?

    where(property_id: PropertyAmenity.where(amenity_id: ids)
                                      .group(:property_id)
                                      .having("COUNT(DISTINCT amenity_id) = ?", ids.size)
                                      .select(:property_id))
  }
  scope :cheapest_first, -> { order(:monthly_rent) }
  scope :newest_first, -> { order(created_at: :desc) }

  def self.search(params)
    listings = published
    listings = listings.in_neighborhood(params[:neighborhood_id]) if params[:neighborhood_id].present?
    listings = listings.under_rent(params[:max_rent]) if params[:max_rent].present?
    listings = listings.available_from(params[:available_from]) if params[:available_from].present?
    listings.with_amenities(params[:amenity_ids])
  end

  def open_for_applications?
    published?
  end

  def available_now?
    available_on <= Date.current
  end

  def cover_photo
    photos.first
  end

  def accepted_application
    applications.find(&:accepted?)
  end

  def to_s
    title
  end

  private

  # A room cannot be offered as available before the listing itself existed.
  # Once a listing is reserved, rented or withdrawn its date is history, so the rule
  # only applies while the host is still writing or advertising the room.
  def available_on_not_in_the_past
    return if available_on.blank?
    return unless draft? || published?
    return unless new_record? || will_save_change_to_available_on?

    reference_date = (created_at || Time.current).to_date
    if available_on < reference_date
      errors.add(:available_on, "can't be in the past")
    end
  end
end
