class AfterSignupController < ApplicationController
  include Wicked::Wizard

  steps :add_username, :add_mobile_number

  def show
    @user = current_user
    render_wizard
  end

  def update
    @user = current_user
    @user.update_attribute(:status, step.to_s)
    @user.update_attribute(:status, 'active') if step == steps.last
    @user.update_attributes(user_params)
    render_wizard @user
  end

  def finish_wizard_path
    root_path
  end

  private
  def user_params
    params.require(:user).permit(:username, :email, :password, :mobile_number, :expertise)
  end
  
end
