class ApplicationsController < ApplicationController
  before_action :set_application, except: [ :index, :create ]

  # The inbox and the sent list are both built from the policy scope: the query itself only returns
  # the applications the current user may see.
  def index
    applications = policy_scope(Application).includes(:seeker, listing: { property: :neighborhood }).newest_first
    @received_applications = applications.joins(listing: :property).where(properties: { host_id: current_user.id })
    @sent_applications = applications.where(seeker_id: current_user.id)
    # Moderators may see every application: the scope already returns all of them.
    @all_applications = applications if current_user.moderator?
    @pending_count = @received_applications.count(&:pending?)
  end

  def show
    authorize @application
    @listing = @application.listing
  end

  # Applying happens inside the listing page: the response replaces only the application frame.
  def create
    @listing = Listing.find(params[:listing_id])
    # A listing the user can't see (someone else's draft) is refused before anything about it is answered.
    authorize @listing, :show?
    @application = @listing.applications.build(application_params.merge(seeker: current_user))
    authorize @application

    if @application.save
      NotificationsMailer.with(application: @application).new_application.deliver_later
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
    authorize @application, status == "withdrawn" ? :withdraw? : :decide?

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
    @pending_count = current_user.received_applications.pending.count

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

  # Looked up inside the policy scope: an application that is not the user's (or does not exist) is never
  # loaded, and the attempt lands on the explanation page.
  def set_application
    @application = policy_scope(Application).find_by(id: params[:id])
    raise Pundit::NotAuthorizedError, I18n.t("pundit.application_not_found") if @application.nil?
  end

  def application_params
    params.expect(application: [ :message, :move_in_date, :stay_duration_months ])
  end
end
