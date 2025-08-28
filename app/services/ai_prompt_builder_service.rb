class AiPromptBuilderService
  class << self
    def build_system_prompt(user:, content_mode:, platform: nil, context: nil)
      # Check if user has custom prompt templates (Pro/Enterprise feature)
      if AiConfigService.can_access_feature?(user, :can_edit_prompts)
        custom_prompt = user.prompt_templates
                            .where(content_mode: content_mode, is_active: true)
                            .first
        
        if custom_prompt.present?
          # Use user's custom prompt template with variable replacements
          return apply_prompt_variables(custom_prompt.prompt_text, user: user, platform: platform)
        end
      end
      
      # Default system prompt building
      prompt_parts = []
      
      # Base role prompt based on content mode
      prompt_parts << base_role_prompt(content_mode)
      
      # Add user's personal context (from bio)
      prompt_parts << personal_context_prompt(user) if user.bio.present?
      
      # Add business mission (from mission_statement)  
      prompt_parts << mission_context_prompt(user) if user.mission_statement.present?
      
      # Add skills context
      prompt_parts << skills_context_prompt(user) if user.skills.present? && user.skills.any?
      
      # Add platform-specific instructions
      prompt_parts << platform_specific_prompt(platform) if platform.present?
      
      # Add context-specific instructions
      prompt_parts << context_specific_prompt(context) if context.present?
      
      # Add final instructions
      prompt_parts << final_instructions_prompt(content_mode)
      
      prompt_parts.join("\n\n")
    end
    
    # Apply variables to custom prompt templates
    def apply_prompt_variables(prompt_text, user:, platform: nil)
      variables = {
        '{user_name}' => user.name,
        '{user_bio}' => user.bio,
        '{user_mission}' => user.mission_statement,
        '{user_skills}' => user.skills&.join(', '),
        '{platform_name}' => platform || 'social media',
        '{platform_style}' => platform ? platform_specific_prompt(platform) : ''
      }
      
      result = prompt_text
      variables.each do |var, value|
        result = result.gsub(var, value.to_s)
      end
      
      result
    end
    
    def build_content_generation_prompt(user:, user_prompt:, content_mode:, platform: nil)
      system_prompt = build_system_prompt(
        user: user, 
        content_mode: content_mode, 
        platform: platform,
        context: 'content_generation'
      )
      
      {
        system: system_prompt,
        user: enhance_user_prompt(user_prompt, content_mode, platform)
      }
    end
    
    def build_optimization_prompt(content:, platform:)
      {
        system: optimization_system_prompt(platform),
        user: "Optimize this content: #{content}\n\nMake it more engaging while keeping the core message and authentic voice. Output ONLY the optimized content with no wrapper text."
      }
    end
    
    def build_suggestion_prompt(user:, context:)
      system_prompt = build_system_prompt(
        user: user,
        content_mode: user.content_mode,
        context: 'suggestions'
      )
      
      {
        system: system_prompt,
        user: "Based on this context: #{context}\n\nSuggest 3 different social media post ideas that align with my business and expertise."
      }
    end
    
    private
    
    def base_role_prompt(content_mode)
      AiConfigService.get_ai_role(content_mode)
    end
    
    def personal_context_prompt(user)
      "PERSONAL BACKGROUND:\n#{user.bio}"
    end
    
    def mission_context_prompt(user)
      "BUSINESS MISSION & PHILOSOPHY:\n#{user.mission_statement}"
    end
    
    def skills_context_prompt(user)
      skills_text = user.skills.join(', ')
      "EXPERTISE & SKILLS:\n#{skills_text}\n\nNote: Weave these naturally into content when relevant, but avoid just listing skills."
    end
    
    def platform_specific_prompt(platform)
      config = AiConfigService.get_platform(platform)
      hints = config[:style_hints]
      char_limits = config[:char_limits]
      hashtag_count = config[:hashtag_count]
      
      "CONTENT STYLE:\n" +
      "- #{hints[:tone]}\n" +
      "- #{hints[:focus]}\n" +
      "- #{hints[:engagement]}\n" +
      "- Include #{hashtag_count[:min]}-#{hashtag_count[:max]} relevant hashtags\n" +
      "- Aim for #{char_limits[:optimal]} words (#{char_limits[:min]}-#{char_limits[:max]} range)"
    end
    
    def context_specific_prompt(context)
      case context.to_s
      when 'content_generation'
        "TASK: Generate original social media content based on the user's request."
      when 'suggestions'
        "TASK: Provide 3 distinct post ideas that the user can develop further."
      when 'optimization'
        "TASK: Improve existing content while maintaining the original voice and message."
      else
        "TASK: Create social media content that aligns with the user's goals."
      end
    end
    
    def final_instructions_prompt(content_mode)
      base_instructions = [
        "CRITICAL OUTPUT REQUIREMENTS:",
        "- Output ONLY the post content itself - no introductions, explanations, or wrapper text",
        "- Do NOT mention any specific platform names in the content",
        "- Do NOT include phrases like 'Here's your post' or 'Here's an optimized version'",
        "- Do NOT use quotation marks around the content",
        "- Write in the user's authentic voice based on their background",
        "- Avoid corporate buzzwords, jargon, or overly salesy language",
        "- Be specific and valuable rather than generic",
        "- Include genuine insights from their experience",
        "- Make it sound natural and human, not AI-generated",
        "- Weave expertise naturally into the content"
      ]
      
      extra_guidelines = AiConfigService.get_extra_guidelines(content_mode)
      all_instructions = base_instructions + extra_guidelines.map { |g| "- #{g}" }
      all_instructions.join("\n")
    end
    
    def optimization_system_prompt(platform)
      "You are a social media optimization expert. Make content more engaging while maintaining the authentic voice. Output ONLY the optimized content - no introductions, explanations, or wrapper text. Never mention specific platform names in the content."
    end
    
    def enhance_user_prompt(user_prompt, content_mode, platform)
      "Create a #{content_mode} social media post based on: #{user_prompt}\n\nREMEMBER: Output ONLY the post content itself. No introductions, no 'Here's your post', no quotation marks, no platform mentions."
    end
  end
end