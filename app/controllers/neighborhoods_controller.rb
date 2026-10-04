class NeighborhoodsController < ApplicationController
  def index
    @neighborhoods = Neighborhood.by_name
    @property_counts = Property.group(:neighborhood_id).count
    @published_counts = Listing.published.joins(:property).group("properties.neighborhood_id").count
  end

  def show
    @neighborhood = Neighborhood.find(params[:id])
    @listings = Listing.published.in_neighborhood(@neighborhood)
                       .includes(:photos, property: :neighborhood).cheapest_first
  end
end
