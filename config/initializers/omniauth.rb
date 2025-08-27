# SECURE AUTH0 CONFIGURATION - Using official Auth0 docs configuration
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :auth0,
           ENV['AUTH0_CLIENT_ID'],
           ENV['AUTH0_CLIENT_SECRET'],
           ENV['AUTH0_DOMAIN'],
           callback_path: '/auth/callback',
           authorize_params: {
             scope: 'openid profile email'
           }
end

# SECURITY: Allow GET requests for Auth0 (required for omniauth)
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true

# Set failure endpoint
OmniAuth.config.on_failure = Proc.new do |env|
  Auth::OmniauthController.action(:failure).call(env)
end