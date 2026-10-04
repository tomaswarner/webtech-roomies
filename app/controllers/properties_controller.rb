class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:neighborhood, :host).by_address
  end

  def show
    @property = Property.includes(:neighborhood, :host, :amenities).find(params[:id])
    @listings = @property.listings.visible.includes(:photos, property: :neighborhood).order(:status, :monthly_rent)
    @reviews = @property.reviews.includes(:seeker).newest_first
  end
end
