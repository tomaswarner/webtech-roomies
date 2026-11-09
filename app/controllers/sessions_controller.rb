class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  # Account pages: there is no record to authorize.
  skip_after_action :verify_pundit_authorization
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(email: params[:email].to_s.strip.downcase, password: params[:password].to_s)
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Welcome back, #{user.first_name}."
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "You signed out."
  end
end
