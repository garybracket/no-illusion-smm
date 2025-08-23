require 'net/http'
require 'json'

class AiContentService
  CLAUDE_API_URL = 'https://api.anthropic.com/v1/messages'
  MODEL = 'claude-3-haiku-20240307' # Fast, affordable model for content generation
  MAX_TOKENS = 1024
  
  class << self
    def generate_post(user:, prompt:, platform: nil, content_mode: nil)
      content_mode ||= user.content_mode
      
      # Build the system prompt based on user's profile
      system_prompt = build_system_prompt(user, content_mode, platform)
      
      # Make API call to Claude
      response = call_claude_api(system_prompt, prompt)
      
      if response[:success]
        {
          success: true,
          content: response[:content],
          ai_generated: true,
          provider: 'anthropic',
          model: MODEL,
          tokens_used: response[:usage][:output_tokens]
        }
      else
        {
          success: false,
          error: response[:error],
          fallback_content: generate_fallback_content(prompt, platform)
        }
      end
    rescue => e
      Rails.logger.error "AI Content Service Error: #{e.message}"
      {
        success: false,
        error: e.message,
        fallback_content: generate_fallback_content(prompt, platform)
      }
    end
    
    def generate_suggestions(user:, context:)
      prompt = "Based on this context: #{context}\n\nSuggest 3 different social media posts."
      generate_post(user: user, prompt: prompt)
    end
    
    def optimize_content(content:, platform:)
      prompt = "Optimize this content for #{platform}: #{content}\n\nMake it more engaging while keeping the core message."
      
      response = call_claude_api(
        "You are a social media optimization expert. Keep responses concise and platform-appropriate.",
        prompt
      )
      
      response[:success] ? response[:content] : content
    end
    
    private
    
    def build_system_prompt(user, content_mode, platform)
      base_prompt = case content_mode
      when 'business'
        "You are a professional content creator for business social media. Create posts that are informative, value-driven, and professional."
      when 'influencer'
        "You are a social media influencer. Create engaging, trendy, and relatable content that encourages interaction."
      when 'personal'
        "You are helping create personal social media posts. Keep it authentic, casual, and genuine."
      else
        "You are a social media content creator. Create appropriate and engaging posts."
      end
      
      # Add user context if available
      if user.mission_statement.present?
        base_prompt += "\n\nBusiness Mission: #{user.mission_statement}"
      end
      
      if user.skills.present? && user.skills.any?
        base_prompt += "\n\nExpertise areas: #{user.skills.join(', ')}"
      end
      
      if platform.present?
        base_prompt += "\n\nOptimize specifically for #{platform}."
      end
      
      base_prompt + "\n\nImportant: Create natural, authentic content without corporate buzzwords or excessive skill-listing."
    end
    
    def call_claude_api(system_prompt, user_prompt)
      api_key = ENV['ANTHROPIC_API_KEY'] || Rails.application.credentials.dig(:ai, :anthropic, :api_key)
      
      return { success: false, error: "Claude API key not configured" } unless api_key.present?
      
      uri = URI(CLAUDE_API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['x-api-key'] = api_key
      request['anthropic-version'] = '2023-06-01'
      
      request.body = {
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: system_prompt,
        messages: [
          {
            role: 'user',
            content: user_prompt
          }
        ]
      }.to_json
      
      response = http.request(request)
      
      if response.code == '200'
        parsed = JSON.parse(response.body)
        {
          success: true,
          content: parsed['content'][0]['text'],
          usage: parsed['usage']
        }
      else
        error_body = JSON.parse(response.body) rescue { 'error' => 'Unknown error' }
        {
          success: false,
          error: error_body['error'] || "API request failed: #{response.code}"
        }
      end
    rescue => e
      {
        success: false,
        error: "API call failed: #{e.message}"
      }
    end
    
    def generate_fallback_content(prompt, platform)
      # Simple fallback content when AI is unavailable
      platform_text = platform ? " for #{platform}" : ""
      
      "Here's your post#{platform_text}: #{prompt[0..100]}... [Please customize this message to match your voice and add relevant details]"
    end
  end
end