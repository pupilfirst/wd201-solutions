class ApplicationController < ActionController::Base
  before_action :ensure_user_is_signed_in

  def ensure_user_is_signed_in
    unless current_user
      redirect_to root_path
    end
  end

  def current_user
    return @current_user if instance_variable_defined?(:@current_user)

    current_user_id = session[:current_user_id]
    @current_user = current_user_id ? User.find(current_user_id) : nil
  end
end
