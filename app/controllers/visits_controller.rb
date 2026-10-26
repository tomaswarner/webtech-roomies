class VisitsController < ApplicationController
  before_action :set_visit, only: [ :edit, :update, :confirm, :cancel, :complete ]

  # The host proposes a visit on a shortlisted application.
  def new
    @application = Application.find(params[:application_id])
    @visit = @application.visits.build
  end

  def create
    @application = Application.find(params[:application_id])
    @visit = @application.visits.build(visit_params)

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

  def update
    if @visit.reschedule(visit_params[:scheduled_at])
      redirect_to @visit.application, notice: "Visit rescheduled for #{I18n.l(@visit.scheduled_at, format: :long)}."
    else
      flash.now[:alert] = "The visit could not be rescheduled."
      render :edit, status: :unprocessable_content
    end
  end

  def confirm
    change_status(:confirm, "Visit confirmed.")
  end

  def cancel
    change_status(:cancel, "Visit cancelled.")
  end

  def complete
    change_status(:complete, "Visit marked as completed. The seeker can now review the property.")
  end

  private

  def set_visit
    @visit = Visit.find(params[:id])
  end

  def visit_params
    params.expect(visit: [ :scheduled_at ])
  end

  def change_status(action, notice)
    if @visit.public_send(action)
      redirect_to @visit.application, notice: notice
    else
      redirect_to @visit.application, alert: @visit.errors.full_messages.to_sentence
    end
  end
end
