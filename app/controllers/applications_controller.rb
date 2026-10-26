class ApplicationsController < ApplicationController
  before_action :require_current_user, only: [ :index, :create ]
  before_action :set_application, except: [ :index, :create ]

  def index
    @received_applications = current_user.received_applications
                                         .includes(:seeker, listing: { property: :neighborhood }).newest_first
    @sent_applications = current_user.applications.includes(listing: { property: :neighborhood }).newest_first
    @pending_count = @received_applications.count(&:pending?)
  end

  def show
    @listing = @application.listing
  end

  # Applying happens inside the listing page: the response replaces only the application frame.
  def create
    @listing = Listing.find(params[:listing_id])
    @application = @listing.applications.build(application_params.merge(seeker: current_user))

    if @application.save
      flash.now[:notice] = "Your application was sent to #{@listing.host.name}."
      render partial: "applications/listing_box", locals: { listing: @listing, application: @application, show_flash: true }
    else
      flash.now[:alert] = "Your application could not be sent."
      render partial: "applications/listing_box", locals: { listing: @listing, application: @application, show_flash: true },
             status: :unprocessable_content
    end
  end

  # The host answers (shortlisted, rejected, accepted) and the seeker withdraws by changing the status.
  def update
    @rejected_applications = []
    status = params.expect(application: [ :status ])[:status]

    succeeded =
      case status
      when "accepted"
        rejected = @application.accept
        @rejected_applications = rejected || []
        rejected
      when "withdrawn"
        @application.withdraw_by(current_user)
      else
        @application.update(status: status)
      end

    if succeeded
      flash.now[:notice] = "The application from #{@application.seeker.name} is now #{@application.status}."
    else
      flash.now[:alert] = @application.errors.full_messages.to_sentence
      @application.reload
    end
    @pending_count = current_user ? current_user.received_applications.pending.count : 0

    # Withdrawing happens inside the listing page frame; the host's answers come from the inbox.
    if status == "withdrawn"
      render partial: "applications/listing_box", locals: { listing: @application.listing, application: @application, show_flash: true }
    else
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @application, notice: flash.now[:notice], alert: flash.now[:alert] }
      end
    end
  end

  private

  def set_application
    @application = Application.find(params[:id])
  end

  def application_params
    params.expect(application: [ :message, :move_in_date, :stay_duration_months ])
  end
end
