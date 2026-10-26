class AmenitiesController < ApplicationController
  before_action :set_amenity, only: [ :show, :edit, :update, :destroy ]

  def index
    @amenities = Amenity.by_name
    @property_counts = PropertyAmenity.group(:amenity_id).count
  end

  def show
    @properties = @amenity.properties.includes(:neighborhood).by_address
  end

  def new
    @amenity = Amenity.new
  end

  def create
    @amenity = Amenity.new(amenity_params)

    if @amenity.save
      redirect_to amenities_path, notice: "Amenity created."
    else
      flash.now[:alert] = "The amenity could not be created."
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @amenity.update(amenity_params)
      redirect_to amenities_path, notice: "Amenity updated."
    else
      flash.now[:alert] = "The amenity could not be updated."
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @amenity.destroy
      redirect_to amenities_path, notice: "Amenity deleted."
    else
      redirect_to amenities_path, alert: "The amenity can't be deleted: #{@amenity.errors.full_messages.to_sentence}."
    end
  end

  private

  def set_amenity
    @amenity = Amenity.find(params[:id])
  end

  def amenity_params
    params.expect(amenity: [ :name ])
  end
end
