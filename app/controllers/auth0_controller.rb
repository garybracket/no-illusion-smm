class Auth0Controller < ApplicationController
  skip_before_action :authenticate_user!
  before_action :initialize_auth0_service

  # Redirect to Auth0 for authentication
  def login
    state = SecureRandom.hex(16)
    session[:auth0_state] = state

    screen_hint = params[:screen_hint] # 'signup' or nil for login
    authorization_url = @auth0_service.authorization_url(state, screen_hint)
    redirect_to authorization_url, allow_other_host: true
  end

  # Handle Auth0 callback
  def callback
    code = params[:code]
    state = params[:state]

    # Verify state parameter (CSRF protection)
    unless state && state == session[:auth0_state]
      Rails.logger.error "Auth0 state mismatch. Expected: #{session[:auth0_state]}, Got: #{state}"
      redirect_to root_path, alert: "Authentication failed - invalid state parameter"
      return
    end

    # Clear the state from session
    session.delete(:auth0_state)

    unless code
      Rails.logger.error "Auth0 callback missing authorization code"
      redirect_to root_path, alert: "Authentication failed - no authorization code"
      return
    end

    # Handle the callback
    result = @auth0_service.handle_callback(code, state)

    if result[:success]
      user = result[:user]
      Rails.logger.info "Auth0 authentication successful for user: #{user.email}"

      # Sign in the user through Devise
      sign_in(user)

      # Store tokens if needed (optional)
      session[:auth0_access_token] = result[:tokens][:access_token]

      redirect_to dashboard_path, notice: "Successfully logged in!"
    else
      Rails.logger.error "Auth0 authentication failed: #{result[:error]}"
      redirect_to root_path, alert: "Authentication failed: #{result[:error]}"
    end
  end

  # Handle Auth0 logout
  def logout
    # Clear Rails session
    sign_out(current_user) if current_user
    reset_session

    # Redirect to Auth0 logout URL to clear Auth0 session
    logout_url = @auth0_service.logout_url(root_url)
    redirect_to logout_url, allow_other_host: true
  end

  private

  def initialize_auth0_service
    @auth0_service = Auth0Service.new
  rescue => e
    Rails.logger.error "Failed to initialize Auth0 service: #{e.message}"
    redirect_to root_path, alert: "Authentication service unavailable"
  end
end
