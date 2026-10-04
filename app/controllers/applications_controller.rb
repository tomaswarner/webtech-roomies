class ApplicationsController < ApplicationController
  def index
    @applications = Application.includes(:seeker, listing: { property: :neighborhood }).newest_first
  end

  def show
    @application = Application.includes(:seeker, :visits, listing: { property: [ :neighborhood, :host ] }).find(params[:id])
    @listing = @application.listing
  end
end
