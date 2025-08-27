class PlatformConnectionsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @connections = current_user.platform_connections.includes(:user)
  end
  
  def linkedin_callback
    auth = request.env['omniauth.auth']
    
    unless auth&.provider == 'linkedin'
      redirect_to dashboard_path, alert: 'LinkedIn connection failed'
      return
    end
    
    begin
      connection = current_user.platform_connections.find_or_initialize_by(platform_name: 'linkedin')
      
      connection.assign_attributes(
        access_token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token,
        expires_at: auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil,
        settings: {
          profile_id: auth.uid,
          name: auth.info.name,
          profile_url: auth.info.urls&.[]('public_profile')
        },
        is_active: true
      )
      
      if connection.save
        Rails.logger.info "LinkedIn connected for user #{current_user.id}: #{auth.info.name}"
        redirect_to dashboard_path, notice: 'LinkedIn connected successfully! You can now post to LinkedIn.'
      else
        Rails.logger.error "LinkedIn connection failed for user #{current_user.id}: #{connection.errors.full_messages}"
        redirect_to dashboard_path, alert: 'Failed to save LinkedIn connection. Please try again.'
      end
      
    rescue => e
      Rails.logger.error "LinkedIn callback error: #{e.message}"
      redirect_to dashboard_path, alert: 'LinkedIn connection failed. Please try again.'
    end
  end
  
  def disconnect
    platform = params[:platform]
    connection = current_user.platform_connections.find_by(platform_name: platform)
    
    if connection&.destroy
      redirect_to dashboard_path, notice: "#{platform.titleize} disconnected successfully"
    else
      redirect_to dashboard_path, alert: "Failed to disconnect #{platform.titleize}"
    end
  end
  
  def test_post
    platform = params[:platform]
    connection = current_user.platform_connections.for_platform(platform).active.first
    
    unless connection&.valid_connection?
      render json: { success: false, error: "No active #{platform} connection" }, status: :unprocessable_entity
      return
    end
    
    case platform
    when 'linkedin'
      result = LinkedinApiService.test_post(connection)
    when 'facebook'
      facebook_service = FacebookApiService.new(current_user)
      result = facebook_service.test_connection(connection.id)
    else
      result = { success: false, error: "Platform #{platform} not supported yet" }
    end
    
    render json: result
  end
end