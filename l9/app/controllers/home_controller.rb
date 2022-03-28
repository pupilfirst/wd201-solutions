class HomeController < ApplicationController
  skip_before_action :ensure_user_is_signed_in

  def index
    if current_user.present?
      redirect_to todos_path
    else
      render "index"
    end
  end
end
