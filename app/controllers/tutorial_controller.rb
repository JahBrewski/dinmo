class TutorialController < ApplicationController
  before_filter :load_user

  def step1
  end

  def step2
  end

  def step3
  end

  def step4
  end

  protected

  def load_user
    @user = current_user
  end
end
