class ListingsController < ApplicationController
  before_action :set_listing, only: [ :edit, :update, :destroy ]

  def index
    @neighborhoods = Neighborhood.by_name
    @listings = Listing.search(search_params)
                       .with_attached_photos.includes(property: :neighborhood)
                       .newest_first
  end

  def show
    @listing = Listing.visible_to(current_user).with_attached_photos
                      .includes(property: [ :neighborhood, :host, :amenities ]).find(params[:id])
    @property = @listing.property
    @reviews = @property.reviews.includes(:seeker).newest_first
    @application = current_user&.applications&.find_by(listing: @listing) || Application.new(listing: @listing)
  end

  def new
    @property = Property.find(params[:property_id])
    @listing = @property.listings.build
  end

  def create
    @property = Property.find(params[:property_id])
    @listing = @property.listings.build(listing_params)

    if @listing.save
      redirect_to @listing, notice: "Listing created as a draft. Publish it when it is ready."
    else
      flash.now[:alert] = "The listing could not be created."
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  # The edit form and the lifecycle buttons (publish, withdraw, mark as rented) both send their changes here.
  def update
    if @listing.update(listing_params)
      notice = @listing.saved_change_to_status? ? "The listing is now #{@listing.status}." : "Listing updated."
      redirect_to @listing, notice: notice
    elsif listing_params.key?(:status)
      redirect_to @listing, alert: @listing.errors.full_messages.to_sentence
    else
      flash.now[:alert] = "The listing could not be updated."
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @listing.destroy
      redirect_to @listing.property, status: :see_other, notice: "Listing deleted."
    else
      redirect_to @listing, status: :see_other, alert: "The listing can't be deleted: #{@listing.errors.full_messages.to_sentence}. " \
                                   "Withdraw it instead."
    end
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def listing_params
    params.expect(listing: [ :title, :monthly_rent, :deposit, :available_on, :minimum_stay_months, :furnished,
                             :private_bathroom, :description, :house_rules, :status, photos: [] ])
  end

  def search_params
    params.permit(:neighborhood_id, :max_rent, :available_from)
  end
end
