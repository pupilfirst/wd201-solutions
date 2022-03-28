class UsersController < ApplicationController
  skip_before_action :ensure_user_is_signed_in

  # POST /users
  def create
    if User.exists?(email: params[:email])
      flash[:error] = "There is already an account with that email. Sign in instead."
      redirect_to new_session_path
      return
    end

    user = User.new(first_name: params[:first_name], last_name: params[:last_name], email: params[:email], password: params[:password])

    if user.save
      flash[:notice] = "You have successfully signed up."
      session[:current_user_id] = user.id
      redirect_to root_url
    else
      flash[:error] = user.errors.full_messages.join(", ")
      redirect_to new_user_path
    end
  end
end
