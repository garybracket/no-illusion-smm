class ProfileController < ApplicationController
  before_action :authenticate_user!
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    
    if @user.update(user_params)
      redirect_to dashboard_path, notice: 'Profile updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def setup_gary_profile
    result = ProfileSetupService.setup_gary_profile(current_user)
    
    if result[:success]
      redirect_to dashboard_path, notice: result[:message]
    else
      redirect_to dashboard_path, alert: "Profile setup failed: #{result[:error]}"
    end
  end
  
  def add_skill
    skill_name = params[:skill_name]
    result = ProfileSetupService.add_custom_skill(current_user, skill_name)
    
    if result[:success]
      redirect_to edit_user_profile_path, notice: result[:message]
    else
      redirect_to edit_user_profile_path, alert: result[:error]
    end
  end
  
  def remove_skill
    skill_name = params[:skill_name]
    result = ProfileSetupService.remove_skill(current_user, skill_name)
    
    if result[:success]
      redirect_to edit_user_profile_path, notice: result[:message]
    else
      redirect_to edit_user_profile_path, alert: result[:error]
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :bio, :mission_statement, :content_mode, :ai_enabled, :ai_preferences, skills: [])
  end
end