class ReviewsController < ApplicationController
  before_action :require_current_user, only: [ :new, :create ]
  before_action :set_property, only: [ :new, :create ]
  before_action :set_review, only: [ :edit, :update, :destroy ]

  def new
    @review = @property.reviews.build(visit: reviewable_visits.find_by(id: params[:visit_id]))
  end

  def create
    @review = @property.reviews.build(review_params.merge(seeker: current_user))
    @review.visit = reviewable_visits.find_by(id: review_params[:visit_id])

    if @review.save
      redirect_to @property, notice: "Thanks! Your review was published."
    else
      flash.now[:alert] = "The review could not be published."
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @review.update(review_params.except(:visit_id))
      redirect_to @review.property, notice: "Review updated."
    else
      flash.now[:alert] = "The review could not be updated."
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @review.destroy
    redirect_to @review.property, notice: "Review deleted."
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.expect(review: [ :visit_id, :rating, :comment ])
  end

  # Only the current user's own visits to this property can be reviewed; the model checks they are completed.
  def reviewable_visits
    @reviewable_visits ||= current_user.visits.where.missing(:review)
                                       .joins(application: :listing).where(listings: { property_id: @property.id })
  end
  helper_method :reviewable_visits
end
