class ProfilesController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      flash.now[:alert] = "Your profile could not be updated."
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = current_user
    authorize @user
  end

  def profile_params
    params.expect(user: [ :name, :email, :phone, :bio ])
  end
end
