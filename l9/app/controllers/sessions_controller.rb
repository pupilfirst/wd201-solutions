class SessionsController < ApplicationController
  skip_before_action :ensure_user_is_signed_in, only: [:new, :create]

  # POST /session
  def create
    user = User.find_by(email: params[:email])

    if user.present? && user.authenticate(params[:password])
      flash[:notice] = "You are now signed in."
      session[:current_user_id] = user.id
      redirect_to todos_path
    else
      flash[:error] = "We're sorry, but we could not verify your credentials."
      redirect_to new_session_path
    end
  end

  # DELETE /session
  def destroy
    session[:current_user_id] = nil
    flash[:notice] = "You have successfully signed out."
    redirect_to root_path
  end
end
