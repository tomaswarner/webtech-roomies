class ReportsController < ApplicationController
  # Moderators review the reports. Taking the listing down is done from the listing page (Withdraw).
  def index
    authorize Report
    @reports = policy_scope(Report).includes(:reporter, :resolved_by, listing: { property: :neighborhood }).newest_first
  end

  def new
    @listing = Listing.find(params[:listing_id])
    authorize @listing, :show?
    @report = @listing.reports.build
    authorize @report
  end

  def create
    @listing = Listing.find(params[:listing_id])
    authorize @listing, :show?
    @report = @listing.reports.build(report_params.merge(reporter: current_user))
    authorize @report

    if @report.save
      redirect_to @listing, notice: "Thanks. A moderator will review your report."
    else
      flash.now[:alert] = "The report could not be sent."
      render :new, status: :unprocessable_content
    end
  end

  # Resolve or dismiss a report.
  def update
    @report = Report.find(params[:id])
    authorize @report

    if @report.update(status: params.expect(report: [ :status ])[:status], resolved_by: current_user)
      redirect_to reports_path, notice: "The report is now #{@report.status}."
    else
      redirect_to reports_path, alert: @report.errors.full_messages.to_sentence
    end
  end

  private

  def report_params
    params.expect(report: [ :reason, :details ])
  end
end
