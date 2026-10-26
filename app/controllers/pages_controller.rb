class PagesController < ApplicationController
  def home
    @featured_listings = Listing.published.with_attached_photos.includes(property: :neighborhood).newest_first.limit(3)
    @neighborhoods = Neighborhood.by_name
  end
end
