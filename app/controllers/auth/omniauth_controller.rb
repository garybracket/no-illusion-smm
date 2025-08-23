class Auth::OmniauthController < ApplicationController
  skip_before_action :authenticate_user!
  
  # SECURITY: Handle Auth0 callback securely
  def auth0
    # SECURITY: Validate the omniauth response
    auth = request.env['omniauth.auth']
    unless auth&.provider == 'auth0'
      redirect_to root_path, alert: 'Authentication failed'
      return
    end

    user = User.from_omniauth(auth)
    
    if user&.persisted?
      # SECURITY: Sign in user through Devise (maintains security checks)
      sign_in_and_redirect user, event: :authentication
    else
      # SECURITY: Log failed authentication attempts
      Rails.logger.warn "Auth0 authentication failed for #{auth&.info&.email}"
      redirect_to root_path, alert: 'Authentication failed. Please try again.'
    end
  end

  # SECURITY: Handle authentication failures
  def failure
    Rails.logger.warn "Auth0 authentication error: #{params[:message]}"
    redirect_to root_path, alert: 'Authentication failed. Please try again.'
  end

  # SECURITY: Handle Auth0 logout
  def logout
    # Sign out from Devise session
    sign_out(current_user) if current_user
    
    # Redirect to Auth0 logout URL to clear Auth0 session
    auth0_logout_url = "https://#{ENV['AUTH0_DOMAIN']}/v2/logout?returnTo=#{CGI.escape(root_url)}"
    redirect_to auth0_logout_url, allow_other_host: true
  end
end
