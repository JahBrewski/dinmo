class UsersController < ApplicationController
  before_filter :load_user, :only => [:available, :unavailable]
  JON_MCEWEN = User.find_by username: "Try it out!"
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
      if params[:commit] == "Person"
        @users = User.search(params[:search]).where(available: true).where(business: false) | [JON_MCEWEN]
      else
        @users = User.search(params[:search]).where(available: true).where(business: true) | [JON_MCEWEN]
      end
    else
      @users = [JON_MCEWEN]
    end
  end

  protected

    def load_user
      @user = User.find(params[:id])
    end
end
