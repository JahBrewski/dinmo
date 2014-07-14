class UsersController < ApplicationController
  before_filter :load_user, :only => [:available, :unavailable]
  JON_MCEWEN = User.find_by username: "jonmcewen"
  def show
  end

  def available
    @user.available!
  end

  def unavailable
    @user.unavailable!
  end

  def index
    if params[:search]
      @users = User.search(params[:search]) | [JON_MCEWEN]
    else
      @users = [JON_MCEWEN]
    end
  end

  protected

    def load_user
      @user = User.find(params[:id])
    end
end
