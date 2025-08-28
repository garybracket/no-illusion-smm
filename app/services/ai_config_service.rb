# AI Configuration Service - Centralized config for scalability and freemium tiers
class AiConfigService
  class << self
    # Feature Tiers (componentized for freemium model)
    def feature_tiers
      {
        'free' => {
          name: 'Free',
          ai_generations_per_month: 5,
          can_use_ai: true,
          can_edit_prompts: false,  # Can't customize prompts
          can_add_content_modes: false,
          available_content_modes: ['business'],  # Only business mode
          available_platforms: ['linkedin'],  # Only LinkedIn
          can_schedule_posts: false,
          can_use_analytics: false
        },
        'pro' => {
          name: 'Pro',
          ai_generations_per_month: 100,
          can_use_ai: true,
          can_edit_prompts: true,  # CAN customize prompts
          can_add_content_modes: false,
          available_content_modes: ['business', 'influencer', 'personal'],
          available_platforms: ['linkedin', 'facebook', 'instagram'],
          can_schedule_posts: true,
          can_use_analytics: true
        },
        'enterprise' => {
          name: 'Enterprise',
          ai_generations_per_month: :unlimited,
          can_use_ai: true,
          can_edit_prompts: true,  # Full prompt customization
          can_add_content_modes: true,  # Can create custom modes
          available_content_modes: :all,
          available_platforms: :all,
          can_schedule_posts: true,
          can_use_analytics: true,
          can_white_label: true,
          can_use_own_api_keys: true  # Use their own AI API keys
        }
      }
    end
    
    # Check if user can access a feature
    def can_access_feature?(user, feature)
      tier = user.subscription_tier || 'free'
      tier_config = feature_tiers[tier]
      
      return false unless tier_config
      
      tier_config[feature] == true || tier_config[feature] == :unlimited || tier_config[feature] == :all
    end
    
    # Get available content modes for user's tier
    def available_content_modes(user)
      tier = user.subscription_tier || 'free'
      tier_config = feature_tiers[tier]
      
      return content_modes.keys if tier_config[:available_content_modes] == :all
      
      tier_config[:available_content_modes] || ['business']
    end
    
    # Get available platforms for user's tier
    def available_platforms(user)
      tier = user.subscription_tier || 'free'
      tier_config = feature_tiers[tier]
      
      return platforms.keys if tier_config[:available_platforms] == :all
      
      tier_config[:available_platforms] || ['linkedin']
    end
    # Content Mode Configurations (easily extensible)
    def content_modes
      {
        'business' => {
          name: 'Business',
          description: 'Professional & corporate tone',
          ai_role: 'You are a professional business content creator specializing in authentic, value-driven social media posts. You help small business owners share their expertise and build trust with their audience without corporate buzzwords or salesy language.',
          topics: [
            "Share a lesson learned from a recent project challenge",
            "Discuss the importance of transparent business practices in your industry",
            "Explain a technical concept in simple terms for non-technical business owners",
            "Share insights about process optimization or automation",
            "Discuss industry trends and their impact on small businesses"
          ],
          extra_guidelines: [
            "Focus on providing real business value and insights",
            "Share practical experience and lessons learned",
            "Position as a trusted expert, not a salesperson"
          ]
        },
        'influencer' => {
          name: 'Influencer',
          description: 'Engaging & social media focused',
          ai_role: 'You are a social media strategist helping influencers create engaging, authentic content that builds genuine connections with their audience while showcasing their unique personality and expertise.',
          topics: [
            "Share behind-the-scenes of your work process",
            "Give advice to someone starting in your field",
            "Share a success story from your experience",
            "Discuss current industry trends and your perspective",
            "Share productivity tips or tools you use daily"
          ],
          extra_guidelines: [
            "Focus on building genuine connections",
            "Share personal stories and experiences",
            "Encourage engagement and conversation"
          ]
        },
        'personal' => {
          name: 'Personal',
          description: 'Casual & authentic voice',
          ai_role: 'You are helping create authentic personal social media content that feels genuine and relatable while maintaining professionalism appropriate for the person\'s career and interests.',
          topics: [
            "Share a personal insight from your professional journey",
            "Discuss work-life balance in your field",
            "Share learning experiences or growth moments",
            "Discuss challenges you've overcome in your career",
            "Share appreciation for your team or community"
          ],
          extra_guidelines: [
            "Keep it genuine and relatable",
            "Share personal perspectives and emotions",
            "Balance professional and personal elements"
          ]
        }
        # Easy to add new modes like 'educator', 'consultant', 'creative', etc.
      }
    end
    
    # Platform Configurations (easily extensible)
    def platforms
      {
        'linkedin' => {
          name: 'LinkedIn',
          char_limits: { min: 150, max: 3000, optimal: 300 },
          hashtag_count: { min: 2, max: 5 },
          style_hints: {
            tone: 'Professional but authentic',
            focus: 'Business insights and professional growth',
            engagement: 'End with a thoughtful question'
          }
        },
        'facebook' => {
          name: 'Facebook',
          char_limits: { min: 100, max: 63206, optimal: 250 },
          hashtag_count: { min: 1, max: 3 },
          style_hints: {
            tone: 'Conversational and community-focused',
            focus: 'Personal stories and community building',
            engagement: 'Encourage discussion'
          }
        },
        'instagram' => {
          name: 'Instagram',
          char_limits: { min: 50, max: 2200, optimal: 150 },
          hashtag_count: { min: 5, max: 30, optimal: 10 },
          style_hints: {
            tone: 'Visual-friendly and catchy',
            focus: 'Strong hook and visual complement',
            engagement: 'Include call-to-action'
          }
        },
        'tiktok' => {
          name: 'TikTok',
          char_limits: { min: 30, max: 2200, optimal: 100 },
          hashtag_count: { min: 3, max: 10 },
          style_hints: {
            tone: 'Casual and trendy',
            focus: 'Entertainment and quick tips',
            engagement: 'Hook viewers immediately'
          }
        },
        'twitter' => {
          name: 'Twitter/X',
          char_limits: { min: 10, max: 280, optimal: 200 },
          hashtag_count: { min: 1, max: 2 },
          style_hints: {
            tone: 'Concise and punchy',
            focus: 'Quick thoughts and hot takes',
            engagement: 'Encourage retweets and replies'
          }
        },
        'youtube' => {
          name: 'YouTube',
          char_limits: { min: 100, max: 5000, optimal: 500 },
          hashtag_count: { min: 3, max: 15 },
          style_hints: {
            tone: 'Descriptive and keyword-rich',
            focus: 'Video description and SEO',
            engagement: 'Include links and timestamps'
          }
        }
        # Easy to add new platforms
      }
    end
    
    # Get configuration for a specific content mode
    def get_content_mode(mode)
      content_modes[mode.to_s] || content_modes['business'] # Default to business
    end
    
    # Get configuration for a specific platform
    def get_platform(platform)
      platforms[platform.to_s.downcase] || {
        name: 'General',
        char_limits: { min: 100, max: 500, optimal: 250 },
        hashtag_count: { min: 2, max: 5 },
        style_hints: {
          tone: 'Engaging and authentic',
          focus: 'Value and insights',
          engagement: 'Encourage interaction'
        }
      }
    end
    
    # Get topic suggestions for a content mode
    def get_topics(content_mode)
      mode_config = get_content_mode(content_mode)
      mode_config[:topics] || []
    end
    
    # Get AI role for a content mode
    def get_ai_role(content_mode)
      mode_config = get_content_mode(content_mode)
      mode_config[:ai_role]
    end
    
    # Get extra guidelines for a content mode
    def get_extra_guidelines(content_mode)
      mode_config = get_content_mode(content_mode)
      mode_config[:extra_guidelines] || []
    end
    
    # Check if a platform is supported
    def platform_supported?(platform)
      platforms.key?(platform.to_s.downcase)
    end
    
    # Check if a content mode is supported
    def content_mode_supported?(mode)
      content_modes.key?(mode.to_s)
    end
  end
end