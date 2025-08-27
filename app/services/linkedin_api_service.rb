require 'net/http'
require 'json'

class LinkedinApiService
  LINKEDIN_API_BASE = 'https://api.linkedin.com/v2'
  
  class << self
    def test_post(connection)
      {
        success: true,
        message: "LinkedIn connection is valid for #{connection.settings['name']}",
        profile_id: connection.settings['profile_id']
      }
    rescue => e
      {
        success: false,
        error: "LinkedIn test failed: #{e.message}"
      }
    end
    
    def create_post(connection, content, options = {})
      return { success: false, error: "Invalid connection" } unless connection&.valid_connection?
      
      profile_id = connection.settings['profile_id']
      
      post_data = {
        author: "urn:li:person:#{profile_id}",
        lifecycleState: "PUBLISHED",
        specificContent: {
          "com.linkedin.ugc.ShareContent" => {
            shareCommentary: {
              text: content
            },
            shareMediaCategory: "NONE"
          }
        },
        visibility: {
          "com.linkedin.ugc.MemberNetworkVisibility" => "PUBLIC"
        }
      }
      
      # Add image if provided
      if options[:image_url].present?
        post_data[:specificContent]["com.linkedin.ugc.ShareContent"][:shareMediaCategory] = "IMAGE"
        post_data[:specificContent]["com.linkedin.ugc.ShareContent"][:media] = [
          {
            status: "READY",
            description: {
              text: options[:image_description] || content[0..100]
            },
            media: options[:image_url],
            title: {
              text: options[:image_title] || "Post Image"
            }
          }
        ]
      end
      
      result = make_api_request(
        connection,
        'POST',
        '/ugcPosts',
        post_data
      )
      
      if result[:success]
        {
          success: true,
          post_id: result[:data]['id'],
          post_url: construct_post_url(result[:data]['id']),
          message: "Posted to LinkedIn successfully"
        }
      else
        {
          success: false,
          error: result[:error]
        }
      end
    end
    
    def get_profile(connection)
      return { success: false, error: "Invalid connection" } unless connection&.valid_connection?
      
      # Use the modern LinkedIn OpenID Connect endpoint
      begin
        response = HTTParty.get(
          'https://api.linkedin.com/v2/userinfo',
          headers: {
            'Authorization' => "Bearer #{connection.access_token}",
            'Content-Type' => 'application/json'
          }
        )
        
        if response.success?
          profile_data = response.parsed_response
          {
            success: true,
            profile: {
              'id' => profile_data['sub'],
              'firstName' => profile_data['given_name'],
              'lastName' => profile_data['family_name'],
              'name' => profile_data['name'],
              'email' => profile_data['email'],
              'picture' => profile_data['picture'],
              'locale' => profile_data['locale']
            }
          }
        else
          {
            success: false,
            error: "Failed to fetch profile: #{response.code} - #{response.message}"
          }
        end
      rescue => e
        {
          success: false,
          error: "API request failed: #{e.message}"
        }
      end
    end

    def get_skills(connection)
      return { success: false, error: "Invalid connection" } unless connection&.valid_connection?
      
      result = make_api_request(
        connection,
        'GET',
        '/people/~/skills',
        nil
      )
      
      if result[:success]
        {
          success: true,
          skills: result[:data]
        }
      else
        {
          success: false,
          error: result[:error]
        }
      end
    end
    
    private
    
    def make_api_request(connection, method, endpoint, data = nil)
      uri = URI("#{LINKEDIN_API_BASE}#{endpoint}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      
      case method.upcase
      when 'GET'
        request = Net::HTTP::Get.new(uri)
      when 'POST'
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request.body = data.to_json if data
      else
        return { success: false, error: "Unsupported HTTP method: #{method}" }
      end
      
      request['Authorization'] = "Bearer #{connection.access_token}"
      request['X-Restli-Protocol-Version'] = '2.0.0'
      
      begin
        response = http.request(request)
        
        case response.code.to_i
        when 200..299
          {
            success: true,
            data: response.body.present? ? JSON.parse(response.body) : {}
          }
        when 401
          # Mark connection as inactive due to expired/invalid token
          connection.update(is_active: false)
          {
            success: false,
            error: "LinkedIn authorization expired. Please reconnect your account."
          }
        when 429
          {
            success: false,
            error: "LinkedIn rate limit exceeded. Please try again later."
          }
        else
          error_data = JSON.parse(response.body) rescue {}
          error_message = error_data.dig('message') || "LinkedIn API error (#{response.code})"
          
          {
            success: false,
            error: error_message
          }
        end
        
      rescue JSON::ParserError => e
        {
          success: false,
          error: "Invalid response from LinkedIn API"
        }
      rescue => e
        Rails.logger.error "LinkedIn API request failed: #{e.message}"
        {
          success: false,
          error: "Network error: #{e.message}"
        }
      end
    end
    
    def construct_post_url(post_id)
      # LinkedIn post URLs follow this pattern, though the exact format may vary
      "https://www.linkedin.com/feed/update/#{post_id}/"
    end
  end
end