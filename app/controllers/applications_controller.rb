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

  def edit
  end

  def update
    if @application.editable? && @application.update(application_params)
      redirect_to @application, notice: "Application updated."
    else
      @application.errors.add(:base, "Only pending applications can be edited") unless @application.editable?
      flash.now[:alert] = "The application could not be updated."
      render :edit, status: :unprocessable_content
    end
  end

  def withdraw
    if @application.withdraw_by(current_user)
      flash_message = { notice: "Application withdrawn." }
    else
      flash_message = { alert: @application.errors.full_messages.to_sentence }
    end

    if turbo_frame_request?
      flash_message.each { |type, text| flash.now[type] = text }
      render partial: "applications/listing_box", locals: { listing: @application.listing, application: @application, show_flash: true }
    else
      redirect_back fallback_location: @application, **flash_message
    end
  end

  def shortlist
    answer(@application.shortlist, "#{@application.seeker.name} was shortlisted.")
  end

  def reject
    answer(@application.reject, "#{@application.seeker.name} was rejected.")
  end

  def accept
    rejected = @application.accept
    @rejected_applications = rejected || []
    answer(rejected, "#{@application.seeker.name} was accepted and the listing is now reserved.")
  end

  private

  def set_application
    @application = Application.find(params[:id])
  end

  def application_params
    params.expect(application: [ :message, :move_in_date, :stay_duration_months ])
  end

  # The host answers from the inbox: a Turbo Stream updates the affected rows and the pending count.
  def answer(succeeded, notice)
    message = succeeded ? { notice: notice } : { alert: @application.errors.full_messages.to_sentence }
    @application.reload unless succeeded
    @rejected_applications ||= []
    @pending_count = current_user ? current_user.received_applications.pending.count : 0

    respond_to do |format|
      format.turbo_stream do
        message.each { |type, text| flash.now[type] = text }
        render :answer
      end
      format.html { redirect_back fallback_location: @application, **message }
    end
  end
end
