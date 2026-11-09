class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  # Account pages: there is no record to authorize.
  skip_after_action :verify_pundit_authorization

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome to Roomies, #{@user.first_name}."
    else
      flash.now[:alert] = "Your account could not be created."
      render :new, status: :unprocessable_content
    end
  end

  private

  # No role: every new account is a member. Moderators are set from the seeds or the console.
  def user_params
    params.expect(user: [ :name, :email, :phone, :password, :password_confirmation ])
  end
end
