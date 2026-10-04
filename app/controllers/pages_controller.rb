class PagesController < ApplicationController
  def home
    @featured_listings = Listing.published.includes(:photos, property: :neighborhood).newest_first.limit(3)
    @neighborhoods = Neighborhood.by_name
  end
end
