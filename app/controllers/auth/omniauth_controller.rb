class Auth::OmniauthController < ApplicationController
  skip_before_action :authenticate_user!

  # SECURITY: Handle Auth0 callback securely
  def auth0
    # Debug logging
    Rails.logger.info "Auth0 callback initiated"
    Rails.logger.info "Omniauth env present: #{request.env.key?('omniauth.auth')}"

    # SECURITY: Validate the omniauth response
    auth = request.env["omniauth.auth"]

    unless auth
      Rails.logger.error "No auth data in request.env['omniauth.auth']"
      Rails.logger.error "Request params: #{params.inspect}"
      redirect_to root_path, alert: "Authentication failed - no auth data received"
      return
    end

    unless auth.provider == "auth0"
      Rails.logger.error "Wrong provider: #{auth.provider}"
      redirect_to root_path, alert: "Authentication failed - wrong provider"
      return
    end

    Rails.logger.info "Auth0 user info: #{auth.info.inspect}"

    user = User.from_omniauth(auth)

    if user&.persisted?
      Rails.logger.info "User authenticated: #{user.email}"


      # SECURITY: Sign in user through Devise (maintains security checks)
      sign_in_and_redirect user, event: :authentication
    else
      # SECURITY: Log failed authentication attempts
      Rails.logger.error "Auth0 user creation/lookup failed for #{auth&.info&.email}"
      redirect_to root_path, alert: "Authentication failed. Please try again."
    end
  end

  # SECURITY: Handle authentication failures
  def failure
    Rails.logger.warn "Auth0 authentication error: #{params[:message]}"
    redirect_to root_path, alert: "Authentication failed. Please try again."
  end


  # SECURITY: Handle Auth0 logout
  def logout
    # Clear the Rails session
    reset_session

    # Redirect to Auth0 logout URL to clear Auth0 session
    auth0_domain = Rails.application.credentials.dig(:auth0, :domain) || ENV["AUTH0_DOMAIN"]

    if auth0_domain
      auth0_logout_url = "https://#{auth0_domain}/v2/logout?returnTo=#{CGI.escape(root_url)}"
      redirect_to auth0_logout_url, allow_other_host: true
    else
      # Fallback if Auth0 domain not configured - just redirect to home
      redirect_to root_path, notice: "You have been logged out."
    end
  end
end
