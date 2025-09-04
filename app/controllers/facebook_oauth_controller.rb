class FacebookOauthController < ApplicationController
  before_action :authenticate_user!, except: [ :test_api_access ]

  FACEBOOK_APP_ID = ENV["FACEBOOK_APP_ID"] || Rails.application.credentials.dig(:facebook, :app_id)
  FACEBOOK_APP_SECRET = ENV["FACEBOOK_APP_SECRET"] || Rails.application.credentials.dig(:facebook, :app_secret)

  def connect
    redirect_to authorization_url, allow_other_host: true
  end

  def callback
    Rails.logger.info "Facebook callback params: #{params.inspect}"

    if params[:error]
      Rails.logger.error "Facebook OAuth error: #{params[:error]} - #{params[:error_description]}"
      redirect_to platform_connections_path, alert: "Facebook connection was cancelled or failed: #{params[:error_description]}"
      return
    end

    unless params[:code]
      Rails.logger.error "Facebook OAuth: No authorization code received"
      redirect_to platform_connections_path, alert: "Facebook authentication failed - no authorization code received"
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
          platform_name: "facebook",
          platform_user_id: "no_pages_available",
          access_token: access_token,
          expires_at: 2.months.from_now,
          is_active: true,
          settings: { status: "connected_no_pages", message: "Facebook connected but no business pages found. Create a Facebook business page to enable posting." }
        )

        redirect_to platform_connections_path,
                    notice: "Facebook connected! No business pages found - create a Facebook business page to enable posting.",
                    alert: "Tip: Facebook posting requires a business page. You can still use LinkedIn and other platforms!"
      end
    else
      redirect_to platform_connections_path, alert: "Facebook connection failed: #{result[:error]}"
    end
  end

  def disconnect
    current_user.platform_connections.where(platform_name: "facebook").destroy_all
    redirect_to platform_connections_path, notice: "Facebook pages disconnected successfully"
  end

  # Handle Facebook SDK callback (AJAX)
  def sdk_callback
    Rails.logger.info "Facebook SDK callback: #{params.inspect}"

    access_token = params[:access_token]
    user_info = params[:user_info]

    unless access_token && user_info
      render json: { success: false, error: "Missing access token or user info" }
      return
    end

    # Validate token with Facebook
    validation_result = validate_facebook_token(access_token)

    if validation_result[:valid]
      # Store the connection
      connection = current_user.platform_connections.find_or_initialize_by(
        platform_name: "facebook",
        platform_user_id: user_info["id"] || "sdk_user"
      )

      connection.update!(
        access_token: access_token,
        settings: {
          user_name: user_info["name"],
          email: user_info["email"],
          auth_method: "facebook_sdk",
          permissions: validation_result[:permissions]
        },
        is_active: true,
        expires_at: 2.months.from_now
      )

      render json: {
        success: true,
        message: "Facebook connected successfully via SDK!",
        permissions: validation_result[:permissions]
      }
    else
      render json: {
        success: false,
        error: "Invalid Facebook token: " + validation_result[:error]
      }
    end
  rescue => e
    Rails.logger.error "Facebook SDK callback error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { success: false, error: e.message }
  end

  # Debug endpoint to check app configuration
  def debug_permissions
    # Try to get app info
    app_token = "#{FACEBOOK_APP_ID}|#{FACEBOOK_APP_SECRET}"

    # Get app permissions
    uri = URI("https://graph.facebook.com/v22.0/#{FACEBOOK_APP_ID}/permissions")
    uri.query = { access_token: app_token }.to_query

    response = Net::HTTP.get_response(uri)
    permissions_data = JSON.parse(response.body)

    # Get app info
    uri2 = URI("https://graph.facebook.com/v22.0/#{FACEBOOK_APP_ID}")
    uri2.query = {
      access_token: app_token,
      fields: "name,category,subcategory,namespace,app_domains,auth_dialog_headline"
    }.to_query

    response2 = Net::HTTP.get_response(uri2)
    app_data = JSON.parse(response2.body)

    render json: {
      app_info: app_data,
      permissions: permissions_data,
      oauth_url: authorization_url,
      current_scope: "email"
    }
  rescue => e
    render json: { error: e.message }
  end

  # Test endpoint to make first Marketing API call and unlock advanced access
  def test_api_access
    # Use your actual Marketing API access token from Facebook
    access_token = "EAALybt6plIMBPVEW30J4zP4wg6ZAmg0C8QZB1SlUoxdcnm3NawZCoVXWihqyuszagiPGwsTSUWEHkdCA2ZBf0bWRxyGy8Bdxwq99tEB29FbGw1IFtw7yl7TEJT3xd3MCZCAbJs3IEJrYIHEDz2GrzsEfk3gAJuvfyg3ppauvMZCHKKZCXhzKQAMPZBgfjmNCBJJEfCCX6ZCxG"
    ad_account_id = "1236898354791286"
    campaign_name = "Test Campaign - API Access Unlock"

    # Create Marketing API campaign (Ruby equivalent of Java sample)
    uri = URI("https://graph.facebook.com/v19.0/act_#{ad_account_id}/campaigns")

    params = {
      access_token: access_token,
      objective: "OUTCOME_TRAFFIC",
      status: "PAUSED",
      buying_type: "AUCTION",
      name: campaign_name,
      special_ad_categories: []
    }

    response = Net::HTTP.post_form(uri, params)
    result = JSON.parse(response.body)

    if response.code == "200" && result["id"]
      render json: {
        success: true,
        message: "Marketing API campaign created successfully! Advanced access should unlock in 24 hours.",
        campaign_id: result["id"],
        data: result
      }
    else
      render json: {
        success: false,
        error: result["error"]&.[]("message") || "Marketing API call failed",
        error_details: result["error"],
        data: result
      }
    end
  rescue => e
    render json: { success: false, error: e.message, backtrace: e.backtrace&.first(3) }
  end

  private

  def authorization_url
    params = {
      client_id: FACEBOOK_APP_ID,
      redirect_uri: callback_url,
      scope: "email", # Only use email since it's the only activated permission
      response_type: "code",
      state: SecureRandom.hex(16),
      auth_type: "rerequest" # Force re-request of permissions
    }

    "https://www.facebook.com/v22.0/dialog/oauth?" + params.to_query
  end

  def callback_url
    if Rails.env.production?
      "#{ENV['APP_URL'] || 'https://smm.no-illusion.com'}/facebook/callback"
    else
      # Use IP address instead of localhost for Facebook Business
      port = ENV["PORT"] || ENV["DEV_PORT"] || 3000
      "https://127.0.0.1:#{port}/facebook/callback"
    end
  end

  def exchange_code_for_tokens(code)
    uri = URI("https://graph.facebook.com/v22.0/oauth/access_token")

    params = {
      client_id: FACEBOOK_APP_ID,
      client_secret: FACEBOOK_APP_SECRET,
      redirect_uri: callback_url,
      code: code
    }

    Rails.logger.info "Exchanging Facebook code for token with params: #{params.except(:client_secret, :code).inspect}"

    response = Net::HTTP.post_form(uri, params)
    data = JSON.parse(response.body)

    Rails.logger.info "Facebook token exchange response: #{data.inspect}"

    if data["access_token"]
      { success: true, access_token: data["access_token"] }
    else
      error_message = data["error"]&.[]("message") || data["error_description"] || "Token exchange failed"
      Rails.logger.error "Facebook token exchange failed: #{error_message}"
      { success: false, error: error_message }
    end
  rescue => e
    Rails.logger.error "Facebook token exchange exception: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    { success: false, error: e.message }
  end

  def get_user_pages(access_token)
    uri = URI("https://graph.facebook.com/v22.0/me/accounts")
    uri.query = {
      access_token: access_token,
      fields: "id,name,access_token,category,tasks"
    }.to_query

    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    if data["data"]
      # Filter pages where user has MANAGE permission
      data["data"].select do |page|
        page["tasks"] && page["tasks"].include?("MANAGE")
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
    page_token = get_long_lived_page_token(page["access_token"])

    connection = current_user.platform_connections.find_or_initialize_by(
      platform_name: "facebook",
      platform_user_id: page["id"]
    )

    connection.update!(
      access_token: page_token || page["access_token"],
      settings: {
        page_name: page["name"],
        page_id: page["id"],
        category: page["category"],
        permissions: page["tasks"]
      },
      is_active: true,
      expires_at: nil # Facebook page tokens don't expire if properly generated
    )
  end

  def get_long_lived_page_token(page_token)
    uri = URI("https://graph.facebook.com/v22.0/oauth/access_token")
    uri.query = {
      grant_type: "fb_exchange_token",
      client_id: FACEBOOK_APP_ID,
      client_secret: FACEBOOK_APP_SECRET,
      fb_exchange_token: page_token
    }.to_query

    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    data["access_token"] if data["access_token"]
  rescue => e
    Rails.logger.error "Error getting long-lived Facebook token: #{e.message}"
    nil
  end

  def validate_facebook_token(access_token)
    # Validate the token with Facebook
    uri = URI("https://graph.facebook.com/v22.0/debug_token")
    uri.query = {
      input_token: access_token,
      access_token: "#{FACEBOOK_APP_ID}|#{FACEBOOK_APP_SECRET}"
    }.to_query

    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    Rails.logger.info "Facebook token validation: #{data.inspect}"

    if data["data"] && data["data"]["is_valid"]
      {
        valid: true,
        permissions: data["data"]["scopes"] || [],
        app_id: data["data"]["app_id"],
        user_id: data["data"]["user_id"]
      }
    else
      {
        valid: false,
        error: data["error"]&.[]("message") || "Token validation failed"
      }
    end
  rescue => e
    Rails.logger.error "Facebook token validation error: #{e.message}"
    { valid: false, error: e.message }
  end
end
