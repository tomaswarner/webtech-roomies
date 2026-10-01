class Property < ApplicationRecord
  PROPERTY_TYPES = %w[apartment house studio townhouse].freeze

  belongs_to :host, class_name: "User", inverse_of: :properties
  belongs_to :neighborhood
  has_many :property_amenities, dependent: :destroy
  has_many :amenities, through: :property_amenities
  has_many :listings, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy

  validates :address, presence: true
  validates :property_type, presence: true, inclusion: { in: PROPERTY_TYPES }
  validates :bedrooms_count, numericality: { only_integer: true, greater_than: 0 }
  validates :bathrooms_count, numericality: { only_integer: true, greater_than: 0 }

  scope :by_address, -> { order(:address) }
  scope :in_neighborhood, ->(neighborhood) { where(neighborhood: neighborhood) }

  def to_s
    "#{address}, #{neighborhood.name}"
  end

  def average_rating
    reviews.average(:rating)&.round(1)
  end
end
