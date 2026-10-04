class ListingsController < ApplicationController
  def index
    @neighborhoods = Neighborhood.by_name
    @listings = Listing.search(search_params)
                       .includes(:photos, property: :neighborhood)
                       .newest_first
  end

  def show
    @listing = Listing.visible.includes(:photos, property: [ :neighborhood, :host, :amenities ]).find(params[:id])
    @property = @listing.property
    @reviews = @property.reviews.includes(:seeker).newest_first
  end

  private

  def search_params
    params.permit(:neighborhood_id, :max_rent, :available_from)
  end
end
