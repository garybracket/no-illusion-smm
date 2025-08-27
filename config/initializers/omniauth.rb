# SECURE AUTH0 CONFIGURATION
Rails.application.config.middleware.use OmniAuth::Builder do
  # Auth0 for user authentication (omniauth-auth0 v3.x format)
  # CRITICAL: The order and format of these parameters matters!
  provider :auth0,
           ENV['AUTH0_CLIENT_ID'],
           ENV['AUTH0_CLIENT_SECRET'],
           ENV['AUTH0_DOMAIN'],
           callback_path: '/auth/callback',
           authorize_params: {
             scope: 'openid profile email'
           },
           # Fix for client_id not being sent during token exchange
           client_options: {
             site: "https://#{ENV['AUTH0_DOMAIN']}",
             authorize_url: '/authorize',
             token_url: '/oauth/token',
             userinfo_url: '/userinfo',
             auth_scheme: :request_body  # Send credentials in body, not header
           },
           provider_ignores_state: false  # Re-enable state check for security
  
  # LinkedIn removed - using direct OAuth implementation instead
end

# SECURITY: Allow GET requests for Auth0 (required for omniauth)
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true

# Set failure endpoint
OmniAuth.config.on_failure = Proc.new do |env|
  Auth::OmniauthController.action(:failure).call(env)
end