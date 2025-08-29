class LinkedinOauthController < ApplicationController
  before_action :authenticate_user!
  
  # LinkedIn OAuth v2 configuration
  LINKEDIN_CLIENT_ID = ENV['LINKEDIN_CLIENT_ID'] || Rails.application.credentials.dig(:linkedin, :client_id)
  LINKEDIN_CLIENT_SECRET = ENV['LINKEDIN_CLIENT_SECRET'] || Rails.application.credentials.dig(:linkedin, :client_secret)
  LINKEDIN_SCOPE = 'openid profile w_member_social'
  def self.linkedin_redirect_uri
    if Rails.env.production?
      "#{ENV['APP_URL'] || 'https://smm.no-illusion.com'}/users/auth/linkedin/callback"
    else
      # Use dynamic port to match current development setup
      port = ENV['PORT'] || ENV['DEV_PORT'] || 3000
      "http://localhost:#{port}/users/auth/linkedin/callback"
    end
  end
  
  # Step 1: Redirect to LinkedIn for authorization
  def authorize
    # Check if user is already connected
    if current_user.linkedin_connected?
      Rails.logger.info "LinkedIn OAuth: User #{current_user.id} is already connected to LinkedIn"
      redirect_to dashboard_path, notice: 'You are already connected to LinkedIn!'
      return
    end
    
    # Generate state parameter for CSRF protection
    session[:linkedin_state] = SecureRandom.hex(32)
    
    # Build LinkedIn authorization URL
    params = {
      response_type: 'code',
      client_id: LINKEDIN_CLIENT_ID,
      redirect_uri: self.class.linkedin_redirect_uri,
      state: session[:linkedin_state],
      scope: LINKEDIN_SCOPE
    }
    
    authorization_url = "https://www.linkedin.com/oauth/v2/authorization?" + params.to_query
    
    Rails.logger.info "LinkedIn OAuth: Redirecting user #{current_user.id} to LinkedIn authorization"
    redirect_to authorization_url, allow_other_host: true
  end
  
  # Step 2: Handle callback from LinkedIn
  def callback
    # Check if user is already connected (handles cases where they already connected but callback is called again)
    if current_user.linkedin_connected?
      Rails.logger.info "LinkedIn OAuth: User #{current_user.id} is already connected to LinkedIn, ignoring callback"
      redirect_to dashboard_path, notice: 'You are already connected to LinkedIn!'
      return
    end
    
    # Verify state parameter to prevent CSRF attacks
    unless params[:state] == session[:linkedin_state]
      Rails.logger.error "LinkedIn OAuth: Invalid state parameter for user #{current_user.id}. Expected: #{session[:linkedin_state]}, Got: #{params[:state]}"
      redirect_to dashboard_path, alert: 'LinkedIn connection failed: Invalid state parameter'
      return
    end
    
    # Clear state from session
    session.delete(:linkedin_state)
    
    # Check for error from LinkedIn
    if params[:error]
      Rails.logger.error "LinkedIn OAuth: Error from LinkedIn: #{params[:error]} - #{params[:error_description]}"
      redirect_to dashboard_path, alert: "LinkedIn connection failed: #{params[:error_description]}"
      return
    end
    
    # Exchange authorization code for access token
    token_response = exchange_code_for_token(params[:code])
    
    if token_response[:success]
      # Get user profile information
      profile_response = get_linkedin_profile(token_response[:access_token])
      
      if profile_response[:success]
        # Save connection to database
        save_linkedin_connection(token_response, profile_response[:profile])
        redirect_to dashboard_path, notice: 'LinkedIn connected successfully! You can now post to LinkedIn.'
      else
        Rails.logger.error "LinkedIn OAuth: Profile fetch failed for user #{current_user.id}: #{profile_response[:error]}"
        redirect_to dashboard_path, alert: 'LinkedIn connection failed: Could not fetch profile information'
      end
    else
      Rails.logger.error "LinkedIn OAuth: Token exchange failed for user #{current_user.id}: #{token_response[:error]}"
      redirect_to dashboard_path, alert: 'LinkedIn connection failed: Could not exchange authorization code'
    end
  end
  
  private
  
  def exchange_code_for_token(authorization_code)
    begin
      response = HTTParty.post(
        'https://www.linkedin.com/oauth/v2/accessToken',
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded'
        },
        body: {
          grant_type: 'authorization_code',
          code: authorization_code,
          client_id: LINKEDIN_CLIENT_ID,
          client_secret: LINKEDIN_CLIENT_SECRET,
          redirect_uri: self.class.linkedin_redirect_uri
        }
      )
      
      if response.success?
        token_data = response.parsed_response
        Rails.logger.info "LinkedIn OAuth: Token exchange successful for user #{current_user.id}"
        
        {
          success: true,
          access_token: token_data['access_token'],
          refresh_token: token_data['refresh_token'],
          expires_in: token_data['expires_in']
        }
      else
        Rails.logger.error "LinkedIn OAuth: Token exchange failed - #{response.code}: #{response.body}"
        { success: false, error: "HTTP #{response.code}: #{response.parsed_response}" }
      end
    rescue => e
      Rails.logger.error "LinkedIn OAuth: Token exchange exception - #{e.message}"
      { success: false, error: e.message }
    end
  end
  
  def get_linkedin_profile(access_token)
    begin
      response = HTTParty.get(
        'https://api.linkedin.com/v2/userinfo',
        headers: {
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => 'application/json'
        }
      )
      
      if response.success?
        profile_data = response.parsed_response
        Rails.logger.info "LinkedIn OAuth: Profile fetch successful for user #{current_user.id}"
        
        {
          success: true,
          profile: {
            id: profile_data['sub'],
            name: profile_data['name'],
            given_name: profile_data['given_name'],
            family_name: profile_data['family_name'],
            email: profile_data['email'],
            picture: profile_data['picture']
          }
        }
      else
        Rails.logger.error "LinkedIn OAuth: Profile fetch failed - #{response.code}: #{response.body}"
        { success: false, error: "HTTP #{response.code}: #{response.parsed_response}" }
      end
    rescue => e
      Rails.logger.error "LinkedIn OAuth: Profile fetch exception - #{e.message}"
      { success: false, error: e.message }
    end
  end
  
  # Import LinkedIn profile data to enhance user profile
  def import_profile
    unless current_user.linkedin_connected?
      redirect_to dashboard_path, alert: 'You must connect to LinkedIn first'
      return
    end
    
    result = LinkedinProfileImportService.import_profile_data(current_user)
    
    if result[:success]
      imported_items = result[:imported_data].keys.map(&:to_s).map(&:humanize).join(', ')
      message = imported_items.present? ? 
        "Profile updated from LinkedIn: #{imported_items}" : 
        "LinkedIn profile checked - no new data to import"
      redirect_to dashboard_path, notice: message
    else
      redirect_to dashboard_path, alert: "Profile import failed: #{result[:error]}"
    end
  end
  
  # Export app profile data to LinkedIn (or generate formatted version)
  def export_profile
    unless current_user.linkedin_connected?
      redirect_to dashboard_path, alert: 'You must connect to LinkedIn first'
      return
    end
    
    result = LinkedinProfileExportService.export_profile_data(current_user)
    
    if result[:success]
      # Store formatted profile in session for display
      session[:linkedin_export_data] = result[:formatted_profile]
      redirect_to linkedin_export_preview_path, notice: result[:message]
    else
      redirect_to dashboard_path, alert: "Profile export failed: #{result[:error]}"
    end
  end
  
  # Show formatted profile data for copy-paste to LinkedIn
  def export_preview
    @formatted_profile = session[:linkedin_export_data]
    
    unless @formatted_profile
      redirect_to dashboard_path, alert: 'No export data found. Please try exporting again.'
    end
  end

  private

  def save_linkedin_connection(token_data, profile_data)
    connection = current_user.platform_connections.find_or_initialize_by(platform_name: 'linkedin')
    
    connection.assign_attributes(
      access_token: token_data[:access_token],
      refresh_token: token_data[:refresh_token],
      expires_at: token_data[:expires_in] ? Time.current + token_data[:expires_in].seconds : nil,
      settings: {
        profile_id: profile_data[:id],
        name: profile_data[:name] || "#{profile_data[:given_name]} #{profile_data[:family_name]}",
        email: profile_data[:email],
        picture: profile_data[:picture]
      },
      is_active: true
    )
    
    if connection.save
      Rails.logger.info "LinkedIn connection saved for user #{current_user.id}: #{profile_data[:name]}"
      
      # Automatically import profile data after successful connection
      profile_import_result = LinkedinProfileImportService.import_profile_data(current_user)
      if profile_import_result[:success] && profile_import_result[:imported_data].present?
        Rails.logger.info "LinkedIn profile auto-imported for user #{current_user.id}"
      end
    else
      Rails.logger.error "LinkedIn connection save failed for user #{current_user.id}: #{connection.errors.full_messages}"
      raise "Failed to save LinkedIn connection: #{connection.errors.full_messages.join(', ')}"
    end
  end
end