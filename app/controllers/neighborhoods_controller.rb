class NeighborhoodsController < ApplicationController
  before_action :set_neighborhood, only: [ :show, :edit, :update, :destroy ]

  def index
    @neighborhoods = Neighborhood.by_name
    @property_counts = Property.group(:neighborhood_id).count
    @published_counts = Listing.published.joins(:property).group("properties.neighborhood_id").count
  end

  def show
    @listings = Listing.published.in_neighborhood(@neighborhood)
                       .with_attached_photos.includes(property: :neighborhood).cheapest_first
  end

  def new
    @neighborhood = Neighborhood.new
  end

  def create
    @neighborhood = Neighborhood.new(neighborhood_params)

    if @neighborhood.save
      redirect_to @neighborhood, notice: "Neighborhood created."
    else
      flash.now[:alert] = "The neighborhood could not be created."
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @neighborhood.update(neighborhood_params)
      redirect_to @neighborhood, notice: "Neighborhood updated."
    else
      flash.now[:alert] = "The neighborhood could not be updated."
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @neighborhood.destroy
      redirect_to neighborhoods_path, status: :see_other, notice: "Neighborhood deleted."
    else
      redirect_to @neighborhood, status: :see_other, alert: "The neighborhood can't be deleted: #{@neighborhood.errors.full_messages.to_sentence}."
    end
  end

  private

  def set_neighborhood
    @neighborhood = Neighborhood.find(params[:id])
  end

  def neighborhood_params
    params.expect(neighborhood: [ :name ])
  end
end
