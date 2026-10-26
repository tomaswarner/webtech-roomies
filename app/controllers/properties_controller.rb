class PropertiesController < ApplicationController
  before_action :set_property, only: [ :show, :edit, :update, :destroy ]
  before_action :require_current_user, only: [ :new, :create ]

  def index
    @properties = Property.includes(:neighborhood, :host).by_address
  end

  def show
    @listings = Listing.visible_to(current_user).where(property: @property)
                       .with_attached_photos.includes(property: :neighborhood).order(:status, :monthly_rent)
    @reviews = @property.reviews.includes(:seeker).newest_first
    @reviewable_visits = reviewable_visits
  end

  def new
    @property = current_user.properties.build
  end

  def create
    @property = current_user.properties.build(property_params)

    if @property.save
      redirect_to @property, notice: "Property created. You can now publish a room inside it."
    else
      flash.now[:alert] = "The property could not be created."
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @property.update(property_params)
      redirect_to @property, notice: "Property updated."
    else
      flash.now[:alert] = "The property could not be updated."
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @property.destroy
      redirect_to properties_path, status: :see_other, notice: "Property deleted."
    else
      redirect_to @property, status: :see_other, alert: "The property can't be deleted: #{@property.errors.full_messages.to_sentence}."
    end
  end

  private

  def set_property
    @property = Property.includes(:neighborhood, :host, :amenities).find(params[:id])
  end

  def property_params
    params.expect(property: [ :address, :neighborhood_id, :property_type, :bedrooms_count, :bathrooms_count,
                              :shared_spaces_description, amenity_ids: [] ])
  end

  # Completed visits of the current user to this property that have not been reviewed yet.
  def reviewable_visits
    return Visit.none if current_user.blank?

    current_user.visits.completed.where.missing(:review)
                .joins(application: :listing).where(listings: { property_id: @property.id })
  end
end
