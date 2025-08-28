class FacebookOauthController < ApplicationController
  before_action :authenticate_user!

  FACEBOOK_APP_ID = ENV['FACEBOOK_APP_ID'] || Rails.application.credentials.dig(:facebook, :app_id)
  FACEBOOK_APP_SECRET = ENV['FACEBOOK_APP_SECRET'] || Rails.application.credentials.dig(:facebook, :app_secret)

  def connect
    redirect_to authorization_url
  end

  def callback
    if params[:error]
      redirect_to platform_connections_path, alert: "Facebook connection was cancelled or failed: #{params[:error_description]}"
      return
    end

    unless params[:code]
      redirect_to platform_connections_path, alert: 'Facebook authentication failed - no authorization code received'
      return
    end

    result = exchange_code_for_tokens(params[:code])

    if result[:success]
      # Store user's access token
      access_token = result[:access_token]
      
      # Get user's Facebook pages (business pages they manage)
      pages = get_user_pages(access_token)
      
      if pages.any?
        # Store connection for each page
        pages.each do |page|
          store_page_connection(page, access_token)
        end
        
        redirect_to platform_connections_path, notice: "Successfully connected #{pages.length} Facebook page(s)!"
      else
        # Graceful handling: Store user connection even without pages
        current_user.platform_connections.create!(
          platform_name: 'facebook',
          platform_user_id: 'no_pages_available',
          access_token: access_token,
          expires_at: 2.months.from_now,
          is_active: true,
          settings: { status: 'connected_no_pages', message: 'Facebook connected but no business pages found. Create a Facebook business page to enable posting.' }
        )
        
        redirect_to platform_connections_path, 
                    notice: 'Facebook connected! No business pages found - create a Facebook business page to enable posting.',
                    alert: 'Tip: Facebook posting requires a business page. You can still use LinkedIn and other platforms!'
      end
    else
      redirect_to platform_connections_path, alert: "Facebook connection failed: #{result[:error]}"
    end
  end

  def disconnect
    current_user.platform_connections.where(platform_name: 'facebook').destroy_all
    redirect_to platform_connections_path, notice: 'Facebook pages disconnected successfully'
  end

  private

  def authorization_url
    params = {
      client_id: FACEBOOK_APP_ID,
      redirect_uri: callback_url,
      scope: 'pages_manage_posts,pages_read_engagement,business_management',
      response_type: 'code',
      state: SecureRandom.hex(16)
    }
    
    "https://www.facebook.com/v22.0/dialog/oauth?" + params.to_query
  end

  def callback_url
    if Rails.env.production?
      "https://smm.no-illusion.com/facebook/callback"
    else
      port = ENV['PORT'] || 3000
      "http://localhost:#{port}/facebook/callback"
    end
  end

  def exchange_code_for_tokens(code)
    uri = URI('https://graph.facebook.com/v22.0/oauth/access_token')
    
    params = {
      client_id: FACEBOOK_APP_ID,
      client_secret: FACEBOOK_APP_SECRET,
      redirect_uri: callback_url,
      code: code
    }
    
    response = Net::HTTP.post_form(uri, params)
    data = JSON.parse(response.body)
    
    if data['access_token']
      { success: true, access_token: data['access_token'] }
    else
      { success: false, error: data['error']&.fetch('message', 'Token exchange failed') }
    end
  rescue => e
    { success: false, error: e.message }
  end

  def get_user_pages(access_token)
    uri = URI("https://graph.facebook.com/v22.0/me/accounts")
    uri.query = {
      access_token: access_token,
      fields: 'id,name,access_token,category,tasks'
    }.to_query
    
    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)
    
    if data['data']
      # Filter pages where user has MANAGE permission
      data['data'].select do |page|
        page['tasks'] && page['tasks'].include?('MANAGE')
      end
    else
      []
    end
  rescue => e
    Rails.logger.error "Error fetching Facebook pages: #{e.message}"
    []
  end

  def store_page_connection(page, user_access_token)
    # Get long-lived page access token
    page_token = get_long_lived_page_token(page['access_token'])
    
    connection = current_user.platform_connections.find_or_initialize_by(
      platform_name: 'facebook',
      platform_user_id: page['id']
    )
    
    connection.update!(
      access_token: page_token || page['access_token'],
      settings: {
        page_name: page['name'],
        page_id: page['id'],
        category: page['category'],
        permissions: page['tasks']
      },
      is_active: true,
      expires_at: nil # Facebook page tokens don't expire if properly generated
    )
  end

  def get_long_lived_page_token(page_token)
    uri = URI('https://graph.facebook.com/v22.0/oauth/access_token')
    uri.query = {
      grant_type: 'fb_exchange_token',
      client_id: FACEBOOK_APP_ID,
      client_secret: FACEBOOK_APP_SECRET,
      fb_exchange_token: page_token
    }.to_query
    
    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)
    
    data['access_token'] if data['access_token']
  rescue => e
    Rails.logger.error "Error getting long-lived Facebook token: #{e.message}"
    nil
  end
end