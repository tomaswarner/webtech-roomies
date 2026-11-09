class ListingsController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]
  # The search page only draws the form: the results come from the JSON API (Api::V1::ListingsController),
  # which asks the published scope itself.
  skip_after_action :verify_pundit_authorization, only: :index
  before_action :set_listing, only: [ :edit, :update, :destroy ]

  def index
    authorize Listing
    @neighborhoods = Neighborhood.by_name
    @amenities = Amenity.by_name
  end

  def show
    @listing = Listing.with_attached_photos.includes(property: [ :neighborhood, :host, :amenities ]).find(params[:id])
    authorize @listing
    @property = @listing.property
    @reviews = @property.reviews.includes(:seeker).newest_first
    @application = current_user&.applications&.find_by(listing: @listing) || Application.new(listing: @listing)
  end

  def new
    @property = Property.find(params[:property_id])
    @listing = @property.listings.build
    authorize @listing
  end

  def create
    @property = Property.find(params[:property_id])
    @listing = @property.listings.build(listing_params)
    authorize @listing

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
    authorize @listing
  end

  def listing_params
    params.expect(listing: [ :title, :monthly_rent, :deposit, :available_on, :minimum_stay_months, :furnished,
                             :private_bathroom, :description, :house_rules, :status, photos: [] ])
  end
end
