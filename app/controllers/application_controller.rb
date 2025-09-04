class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Skip authentication for Devise controllers, home page, and Auth0 routes
  before_action :authenticate_user!, unless: :skip_authentication?
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :content_mode ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :bio, :skills, :mission_statement, :content_mode, :ai_enabled, :ai_preferences ])
  end

  # Helper method for Auth0 authentication URLs (using Auth0 Ruby SDK)
  def auth0_login_url(mode = "login")
    # Use our Auth0 controller with screen_hint parameter
    if mode == "signup"
      auth0_login_path + "?screen_hint=signup"
    else
      auth0_login_path
    end
  end
  helper_method :auth0_login_url

  private

  def skip_authentication?
    devise_controller? || controller_name == "home" || controller_name == "auth0"
  end
end
