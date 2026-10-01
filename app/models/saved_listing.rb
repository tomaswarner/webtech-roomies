class SavedListing < ApplicationRecord
  belongs_to :seeker, class_name: "User", inverse_of: :saved_listings
  belongs_to :listing

  validates :listing_id, uniqueness: { scope: :seeker_id, message: "is already saved" }
end
