class StaticPagesController < ApplicationController
  def home
    if user_signed_in? && current_user.confirmed? == true
      redirect_to users_url
    end
  end
end
