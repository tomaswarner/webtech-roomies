class ListingPhoto < ApplicationRecord
  belongs_to :listing, inverse_of: :photos

  validates :image_url, presence: true, format: { with: %r{\Ahttps?://}i, message: "must be an http(s) URL" }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
