class NotificationsMailer < ApplicationMailer
  # Sent to the host when somebody applies to one of their listings. Delivered through Active Job (deliver_later).
  def new_application
    @application = params[:application]
    @listing = @application.listing
    @host = @listing.host

    mail to: @host.email, subject: "New application for #{@listing.title}"
  end
end
