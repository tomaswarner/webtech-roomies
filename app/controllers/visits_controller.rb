class VisitsController < ApplicationController
  before_action :set_visit, only: [ :edit, :update ]

  # The host proposes a visit on a shortlisted application.
  def new
    @application = find_application
    @visit = @application.visits.build
    authorize @visit
  end

  def create
    @application = find_application
    @visit = @application.visits.build(visit_params)
    authorize @visit

    if @visit.save
      redirect_to @application, notice: "Visit proposed for #{I18n.l(@visit.scheduled_at, format: :long)}."
    else
      flash.now[:alert] = "The visit could not be proposed."
      render :new, status: :unprocessable_content
    end
  end

  # Rescheduling: the visit goes back to proposed until the seeker confirms the new time.
  def edit
  end

  # The reschedule form sends a new time; the confirm, cancel and complete buttons send a new status.
  def update
    if visit_params.key?(:scheduled_at)
      if @visit.reschedule(visit_params[:scheduled_at])
        redirect_to @visit.application, notice: "Visit rescheduled for #{I18n.l(@visit.scheduled_at, format: :long)}."
      else
        flash.now[:alert] = "The visit could not be rescheduled."
        render :edit, status: :unprocessable_content
      end
    elsif @visit.update(status: visit_params[:status])
      redirect_to @visit.application, notice: "The visit is now #{@visit.status}."
    else
      redirect_to @visit.application, alert: @visit.errors.full_messages.to_sentence
    end
  end

  private

  # Applications and visits are looked up inside the policy scope, so an id typed in the URL that is not
  # the user's lands on the explanation page.
  def set_visit
    @visit = policy_scope(Visit).find_by(id: params[:id])
    raise Pundit::NotAuthorizedError, I18n.t("pundit.visit_not_found") if @visit.nil?

    authorize @visit
  end

  def find_application
    application = policy_scope(Application).find_by(id: params[:application_id])
    raise Pundit::NotAuthorizedError, I18n.t("pundit.application_not_found") if application.nil?

    application
  end

  def visit_params
    params.expect(visit: [ :scheduled_at, :status ])
  end
end
