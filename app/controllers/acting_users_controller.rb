class ActingUsersController < ApplicationController
  def update
    user = User.find_by(id: params[:user_id])
    session[:user_id] = user&.id

    notice = user ? "You are now acting as #{user.name}." : "You are now browsing as a visitor."
    redirect_to root_path, notice: notice
  end
end
