class AiPromptBuilderService
  class << self
    def build_system_prompt(user:, content_mode:, platform: nil, context: nil)
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
        user: "Optimize this content for #{platform}: #{content}\n\nMake it more engaging while keeping the core message and maintaining the author's authentic voice."
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
      case content_mode.to_s
      when 'business'
        "You are a professional business content creator specializing in authentic, value-driven social media posts. You help small business owners share their expertise and build trust with their audience without corporate buzzwords or salesy language."
      when 'influencer'
        "You are a social media strategist helping influencers create engaging, authentic content that builds genuine connections with their audience while showcasing their unique personality and expertise."
      when 'personal'
        "You are helping create authentic personal social media content that feels genuine and relatable while maintaining professionalism appropriate for the person's career and interests."
      else
        "You are a social media content strategist focused on creating authentic, engaging posts that reflect the user's genuine voice and expertise."
      end
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
      case platform.to_s.downcase
      when 'linkedin'
        "PLATFORM: LinkedIn\n- Professional tone but authentic and approachable\n- Focus on business insights, professional growth, or industry expertise\n- Use first-person perspective\n- Include relevant hashtags (2-5 max)\n- Aim for 150-300 words\n- Consider asking a thoughtful question to encourage engagement"
      when 'facebook'
        "PLATFORM: Facebook\n- Conversational and community-focused tone\n- Can be more personal and story-driven\n- Encourage discussion and community building\n- Use relevant hashtags sparingly (1-3 max)\n- Aim for 100-250 words"
      when 'instagram'
        "PLATFORM: Instagram\n- Visual-friendly content that complements images\n- Use strategic hashtags (5-10 relevant ones)\n- Shorter, punchy text with strong opening\n- Include call-to-action when appropriate\n- Aim for 50-150 words in caption"
      when 'tiktok'
        "PLATFORM: TikTok\n- Casual, authentic, and trendy tone\n- Hook viewers in first 3 seconds\n- Use relevant trending hashtags\n- Keep text short and punchy\n- Focus on entertainment or quick tips"
      else
        "PLATFORM: General Social Media\n- Adapt tone for professional but approachable audience\n- Keep content engaging and authentic\n- Use appropriate hashtags for platform\n- Aim for optimal length for engagement"
      end
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
        "IMPORTANT GUIDELINES:",
        "- Write in the user's authentic voice based on their background and mission",
        "- Avoid corporate buzzwords, jargon, or overly salesy language", 
        "- Be specific and valuable rather than generic",
        "- Include genuine insights from their experience",
        "- Make it sound like a real person, not an AI",
        "- Don't just list skills - weave expertise naturally into the content"
      ]
      
      case content_mode.to_s
      when 'business'
        base_instructions + [
          "- Focus on providing real business value and insights",
          "- Share practical experience and lessons learned",
          "- Position as a trusted expert, not a salesperson"
        ]
      else
        base_instructions
      end.join("\n")
    end
    
    def optimization_system_prompt(platform)
      "You are a social media optimization expert specializing in improving content performance while maintaining authentic voice. Your goal is to make content more engaging and platform-appropriate without losing the original message or making it sound artificial."
    end
    
    def enhance_user_prompt(user_prompt, content_mode, platform)
      platform_note = platform ? " optimized for #{platform}" : ""
      
      "Create a #{content_mode} social media post#{platform_note} based on this request:\n\n#{user_prompt}\n\nMake sure the content reflects my authentic voice and experience as described in the system context."
    end
  end
end