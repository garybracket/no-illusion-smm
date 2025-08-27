# SECURE AUTH0 + LINKEDIN CONFIGURATION
Rails.application.config.middleware.use OmniAuth::Builder do
  # Auth0 for user authentication (Devise integration)
  provider :auth0,
           ENV['AUTH0_CLIENT_ID'],
           ENV['AUTH0_CLIENT_SECRET'],
           ENV['AUTH0_DOMAIN'],
           callback_path: '/auth/callback',
           authorize_params: {
             scope: 'openid email profile'
           }
  
  # LinkedIn removed - using direct OAuth implementation instead
end

# SECURITY: Allow GET requests for Auth0 (required for omniauth)
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true