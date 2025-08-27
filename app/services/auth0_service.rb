class Auth0Service
  include Rails.application.routes.url_helpers

  def initialize
    @client_id = ENV['AUTH0_CLIENT_ID']
    @client_secret = ENV['AUTH0_CLIENT_SECRET'] 
    @domain = ENV['AUTH0_DOMAIN']
    
    raise "Auth0 credentials not configured" unless @client_id && @client_secret && @domain
  end

  # Generate Auth0 authorization URL
  def authorization_url(state = nil, screen_hint = nil)
    state ||= SecureRandom.hex(16)
    
    params = {
      response_type: 'code',
      client_id: @client_id,
      redirect_uri: callback_url,
      scope: 'openid profile email',
      state: state,
      connection: 'social-media-manager'  # Force use of specific connection
    }
    
    # Add screen_hint for signup vs login
    params[:screen_hint] = screen_hint if screen_hint
    
    "https://#{@domain}/authorize?" + params.to_query
  end

  # Exchange authorization code for tokens and user info
  def handle_callback(code, state)
    # Exchange code for tokens
    token_response = exchange_code_for_tokens(code)
    return { success: false, error: 'Token exchange failed' } unless token_response['access_token']

    # Get user info
    user_info = get_user_info(token_response['access_token'])
    return { success: false, error: 'Failed to get user info' } unless user_info

    # Find or create user
    user = find_or_create_user(user_info)
    return { success: false, error: 'User creation failed' } unless user

    { 
      success: true, 
      user: user,
      tokens: {
        access_token: token_response['access_token'],
        id_token: token_response['id_token']
      }
    }
  rescue => e
    Rails.logger.error "Auth0Service error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    { success: false, error: e.message }
  end

  # Get logout URL
  def logout_url(return_to = nil)
    return_to ||= root_url
    "https://#{@domain}/v2/logout?returnTo=#{CGI.escape(return_to)}&client_id=#{@client_id}"
  end

  private

  def callback_url
    if Rails.env.production?
      "https://smm.no-illusion.com/auth/auth0/callback"
    else
      "http://localhost:3000/auth/auth0/callback"
    end
  end

  def exchange_code_for_tokens(code)
    uri = URI("https://#{@domain}/oauth/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    
    body = {
      grant_type: 'authorization_code',
      client_id: @client_id,
      client_secret: @client_secret,
      code: code,
      redirect_uri: callback_url
    }
    
    request.body = body.to_query

    Rails.logger.info "Auth0 token exchange request to: #{uri}"
    Rails.logger.info "Auth0 token exchange redirect_uri: #{callback_url}"
    Rails.logger.info "Auth0 client_id: #{@client_id}"
    Rails.logger.info "Auth0 client_secret length: #{@client_secret.length}"
    Rails.logger.info "Auth0 client_secret first/last 5: #{@client_secret[0..4]}...#{@client_secret[-5..-1]}"
    Rails.logger.info "Request body being sent: #{request.body}"
    
    response = http.request(request)
    response_body = JSON.parse(response.body)
    
    Rails.logger.info "Auth0 token exchange response code: #{response.code}"
    Rails.logger.info "Auth0 token exchange response: #{response_body.inspect}"
    
    unless response.code == '200'
      Rails.logger.error "Auth0 token exchange failed with status #{response.code}: #{response_body.inspect}"
      Rails.logger.error "Full request body was: #{request.body}"
    end
    
    response_body
  end

  def get_user_info(access_token)
    uri = URI("https://#{@domain}/userinfo")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"

    response = http.request(request)
    JSON.parse(response.body)
  end

  def find_or_create_user(user_info)
    auth0_id = user_info['sub']
    email = user_info['email']
    name = user_info['name'] || user_info['email']&.split('@')&.first

    # Find existing user by Auth0 ID or email
    user = User.find_by(auth0_id: auth0_id) || User.find_by(email: email)

    if user
      # Update Auth0 ID if found by email
      user.update!(auth0_id: auth0_id) if user.auth0_id != auth0_id
    else
      # Create new user
      user = User.create!(
        auth0_id: auth0_id,
        email: email,
        name: name,
        content_mode: :business,
        password: Devise.friendly_token[0, 20]
      )
    end

    user
  end
end