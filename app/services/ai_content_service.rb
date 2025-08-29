require 'net/http'
require 'json'

class AiContentService
  CLAUDE_API_URL = 'https://api.anthropic.com/v1/messages'
  MODEL = ENV['AI_MODEL'] || 'claude-3-haiku-20240307' # Fast, affordable model for content generation
  MAX_TOKENS = (ENV['AI_MAX_TOKENS'] || '1024').to_i
  
  class << self
    def generate_post(user:, prompt: nil, platform: nil, content_mode: nil)
      content_mode ||= user.content_mode
      
      # Auto-generate topic if no prompt provided
      if prompt.blank?
        prompt = generate_automatic_topic(user: user, content_mode: content_mode, platform: platform)
      end
      
      # Build the prompt using new prompt builder service
      prompt_data = AiPromptBuilderService.build_content_generation_prompt(
        user: user,
        user_prompt: prompt,
        content_mode: content_mode,
        platform: platform
      )
      
      # Make API call to Claude
      response = call_claude_api(prompt_data[:system], prompt_data[:user])
      
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
      prompt_data = AiPromptBuilderService.build_suggestion_prompt(user: user, context: context)
      response = call_claude_api(prompt_data[:system], prompt_data[:user])
      
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
          fallback_content: "Here are some general post ideas: 1) Share a recent business insight 2) Ask your audience a question 3) Share a tip from your expertise"
        }
      end
    rescue => e
      Rails.logger.error "AI Suggestions Error: #{e.message}"
      {
        success: false,
        error: e.message,
        fallback_content: "Unable to generate suggestions at this time. Try sharing recent experiences or insights from your work."
      }
    end
    
    def optimize_content(content:, platform:)
      prompt_data = AiPromptBuilderService.build_optimization_prompt(content: content, platform: platform)
      response = call_claude_api(prompt_data[:system], prompt_data[:user])
      
      response[:success] ? response[:content] : content
    end
    
    private
    
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
      "#{prompt[0..100]}... [Please customize this message to match your voice and add relevant details]"
    end
    
    def generate_automatic_topic(user:, content_mode:, platform:)
      # Get topic ideas from configuration service
      topics = AiConfigService.get_topics(content_mode)
      
      # Add skill-based topics if user has skills
      if user.skills.present? && user.skills.any?
        user.skills.first(3).each do |skill|
          topics << "Share practical tips about #{skill}"
          topics << "Discuss recent developments in #{skill}"
        end
      end
      
      # Select random topic
      topics.sample
    end
  end
end