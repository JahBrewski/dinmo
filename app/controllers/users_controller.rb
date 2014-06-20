class UsersController < ApplicationController
  def show
  end

  def index
    if params[:search]
      @users = User.search(params[:search])
    else
      @users = []
    end
  end
end
