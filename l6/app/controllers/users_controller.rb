class UsersController < ApplicationController
  # GET /users
  def index
    render plain: User.all.map { |user| user.to_pleasant_string }.join("\n")
  end

  # POST /users
  def create
    name = params[:name]
    email = params[:email]
    password = params[:password]

    user = User.new(name: name, email: email, password: password)
    user.save!

    render plain: "User has been created with ID #{user.id}"
  end

  # POST /users/login
  def login
    email = params[:email]
    password = params[:password]

    render plain: User.where(email: email, password: password).exists?
  end
end
