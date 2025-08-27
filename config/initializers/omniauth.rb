# SECURE AUTH0 CONFIGURATION
Rails.application.config.middleware.use OmniAuth::Builder do
  # Auth0 for user authentication (omniauth-auth0 v3.x format)
  provider :auth0,
           ENV['AUTH0_CLIENT_ID'],
           ENV['AUTH0_CLIENT_SECRET'],
           ENV['AUTH0_DOMAIN'],
           callback_path: '/auth/callback',
           authorize_params: {
             scope: 'openid profile email'
           }
  
  # LinkedIn removed - using direct OAuth implementation instead
end

# SECURITY: Allow GET requests for Auth0 (required for omniauth)
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true