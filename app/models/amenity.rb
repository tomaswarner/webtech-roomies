class Amenity < ApplicationRecord
  has_many :property_amenities, dependent: :restrict_with_error
  has_many :properties, through: :property_amenities

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :by_name, -> { order(:name) }

  def to_s
    name
  end
end
