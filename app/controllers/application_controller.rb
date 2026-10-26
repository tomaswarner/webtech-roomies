class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  private

  # There is no authentication yet (Assignment 4): the user picked in the navbar acts as the author of every action.
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def require_current_user
    return if current_user

    redirect_back fallback_location: root_path, alert: "Choose the user you are acting as in the navigation bar first."
  end
end
