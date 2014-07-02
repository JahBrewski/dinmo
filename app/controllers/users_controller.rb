class UsersController < ApplicationController
  JON_MCEWEN = User.find_by username: "jonmcewen"
  def show
  end

  def index
    if params[:search]
      @users = User.search(params[:search]) | [JON_MCEWEN]
    else
      @users = [JON_MCEWEN]
    end
  end
end
