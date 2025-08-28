class ProfileController < ApplicationController
  before_action :authenticate_user!
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    
    if @user.update(user_params)
      redirect_to edit_user_profile_path, notice: 'Profile updated successfully!'
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
  
  def destroy
    # Complete user account and data deletion
    user_email = current_user.email
    
    begin
      # Log the deletion for audit purposes
      Rails.logger.info "User account deletion initiated: #{user_email}"
      
      # Revoke social media tokens before deletion
      current_user.platform_connections.each do |connection|
        begin
          case connection.platform_name
          when 'linkedin'
            # LinkedIn tokens auto-expire, but we can revoke if needed
            Rails.logger.info "LinkedIn connection deleted for #{user_email}"
          when 'facebook' 
            # Facebook page tokens - consider revoking if API supports it
            Rails.logger.info "Facebook connection deleted for #{user_email}"
          end
        rescue => e
          Rails.logger.warn "Failed to revoke token for #{connection.platform_name}: #{e.message}"
        end
      end
      
      # Sign out user before deletion (required for Auth0)
      sign_out current_user
      
      # Delete user and all associated data (posts, connections, templates)
      # This will cascade delete due to dependent: :destroy associations
      current_user.destroy!
      
      Rails.logger.info "User account successfully deleted: #{user_email}"
      
      # Redirect to home with confirmation message
      redirect_to root_path, notice: 'Your account and all associated data have been permanently deleted. Thank you for using No iLLusion SMM.'
      
    rescue => e
      Rails.logger.error "Failed to delete user account #{user_email}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      redirect_to edit_user_profile_path, alert: 'Account deletion failed. Please contact support if this continues.'
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :bio, :mission_statement, :content_mode, :ai_enabled, :ai_preferences, skills: [])
  end
end