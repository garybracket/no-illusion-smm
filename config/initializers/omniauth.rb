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
           # Fix for client credentials not being properly authenticated
           client_options: {
             site: "https://#{ENV['AUTH0_DOMAIN']}",
             authorize_url: "https://#{ENV['AUTH0_DOMAIN']}/authorize",
             token_url: "https://#{ENV['AUTH0_DOMAIN']}/oauth/token",
             userinfo_url: "https://#{ENV['AUTH0_DOMAIN']}/userinfo",
             auth_scheme: :basic_auth  # Try Basic authentication
           },
           provider_ignores_state: false
  
  # LinkedIn removed - using direct OAuth implementation instead
end

# SECURITY: Allow GET requests for Auth0 (required for omniauth)
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true

# Set failure endpoint
OmniAuth.config.on_failure = Proc.new do |env|
  Auth::OmniauthController.action(:failure).call(env)
end