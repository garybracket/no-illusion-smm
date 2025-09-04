class FacebookApiService
  include Rails.application.routes.url_helpers

  def initialize(user)
    @user = user
  end

  # Get all Facebook pages connected by the user
  def connected_pages
    @user.platform_connections
         .where(platform_name: "facebook", is_active: true)
         .map do |connection|
      {
        id: connection.platform_user_id,
        name: connection.settings["page_name"],
        category: connection.settings["category"],
        connection_id: connection.id
      }
    end
  end

  # Post content to a specific Facebook page
  def post_to_page(content, page_connection_id, options = {})
    connection = @user.platform_connections.find(page_connection_id)

    unless connection&.platform_name == "facebook"
      return { success: false, error: "Invalid Facebook page connection" }
    end

    page_id = connection.platform_user_id
    access_token = connection.access_token

    post_data = build_post_data(content, options)

    # Post to Facebook Page
    result = make_facebook_post(page_id, access_token, post_data)

    if result[:success]
      {
        success: true,
        post_id: result[:post_id],
        post_url: "https://facebook.com/#{result[:post_id]}",
        platform: "facebook",
        page_name: connection.settings["page_name"]
      }
    else
      { success: false, error: result[:error] }
    end
  end

  # Test connection to ensure page access token is still valid
  def test_connection(page_connection_id)
    connection = @user.platform_connections.find(page_connection_id)
    return { success: false, error: "Connection not found" } unless connection

    page_id = connection.platform_user_id
    access_token = connection.access_token

    # Test by getting page info
    uri = URI("https://graph.facebook.com/v22.0/#{page_id}")
    uri.query = {
      access_token: access_token,
      fields: "id,name,category"
    }.to_query

    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    if response.code == "200" && data["id"]
      { success: true, page_info: data }
    else
      error = data.dig("error", "message") || "Connection test failed"
      { success: false, error: error }
    end
  rescue => e
    { success: false, error: e.message }
  end

  # Get recent posts from a Facebook page (for analytics)
  def get_recent_posts(page_connection_id, limit = 10)
    connection = @user.platform_connections.find(page_connection_id)
    return { success: false, error: "Connection not found" } unless connection

    page_id = connection.platform_user_id
    access_token = connection.access_token

    uri = URI("https://graph.facebook.com/v22.0/#{page_id}/posts")
    uri.query = {
      access_token: access_token,
      fields: "id,message,created_time,likes.summary(true),comments.summary(true),shares",
      limit: limit
    }.to_query

    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    if response.code == "200"
      posts = data["data"]&.map do |post|
        {
          id: post["id"],
          message: post["message"],
          created_time: post["created_time"],
          likes_count: post.dig("likes", "summary", "total_count") || 0,
          comments_count: post.dig("comments", "summary", "total_count") || 0,
          shares_count: post.dig("shares", "count") || 0,
          url: "https://facebook.com/#{post['id']}"
        }
      end

      { success: true, posts: posts || [] }
    else
      error = data.dig("error", "message") || "Failed to fetch posts"
      { success: false, error: error }
    end
  rescue => e
    { success: false, error: e.message }
  end

  private

  def build_post_data(content, options = {})
    post_data = { message: content }

    # Add link if provided
    post_data[:link] = options[:link] if options[:link].present?

    # Add image if provided (URL to image)
    post_data[:picture] = options[:image_url] if options[:image_url].present?

    # Scheduled publishing (future timestamp)
    if options[:scheduled_publish_time].present?
      post_data[:scheduled_publish_time] = options[:scheduled_publish_time].to_i
      post_data[:published] = false
    end

    post_data
  end

  def make_facebook_post(page_id, access_token, post_data)
    uri = URI("https://graph.facebook.com/v22.0/#{page_id}/feed")

    # Add access token to post data
    post_data[:access_token] = access_token

    # Make POST request
    response = Net::HTTP.post_form(uri, post_data)
    data = JSON.parse(response.body)

    if response.code == "200" && data["id"]
      { success: true, post_id: data["id"] }
    else
      error_message = if data["error"]
                       "#{data['error']['type']}: #{data['error']['message']}"
      else
                       "Failed to post to Facebook"
      end

      Rails.logger.error "Facebook posting error: #{error_message}"
      Rails.logger.error "Response: #{response.body}"

      { success: false, error: error_message }
    end
  rescue => e
    Rails.logger.error "Facebook API error: #{e.message}"
    { success: false, error: e.message }
  end
end
