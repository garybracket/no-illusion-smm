# AI Configuration Service - Centralized config for scalability and freemium tiers
class AiConfigService
  class << self
    # Feature Tiers (componentized for freemium model)
    def feature_tiers
      {
        "free" => {
          name: "Free",
          ai_generations_per_month: 10,
          can_use_ai: true,
          can_edit_prompts: false,  # Can't customize prompts
          can_add_content_modes: false,
          available_content_modes: [ "business", "influencer", "personal" ],  # All modes!
          available_platforms: :all,  # All platforms available!
          can_schedule_posts: true,  # Can schedule
          can_use_analytics: false,
          # Usage-based limits (the real restrictions)
          posts_per_hour: 1,  # 1 post per hour max
          scheduled_posts_per_day: 1,  # 1 scheduled post per day
          concurrent_campaigns: 1,  # 1 active campaign
          # Image upload limits
          max_image_size_mb: 8,
          max_images_per_post: 1,
          allowed_image_formats: [ "jpg", "jpeg", "png" ],
          can_upload_images: true,
          can_generate_linkedin_bio: false
        },
        "pro" => {
          name: "Pro",
          ai_generations_per_month: 100,
          can_use_ai: true,
          can_edit_prompts: true,  # CAN customize prompts
          can_add_content_modes: false,
          available_content_modes: :all,
          available_platforms: :all,
          can_schedule_posts: true,
          can_use_analytics: true,
          can_generate_platform_variants: true,  # Different content per platform
          # Usage-based limits (reasonable for $8/mo)
          posts_per_hour: 5,  # 5 posts per hour max
          scheduled_posts_per_day: 10,  # 10 scheduled posts per day
          concurrent_campaigns: 3,  # 3 active campaigns
          # Image upload limits
          max_image_size_mb: 15,
          max_images_per_post: 4,
          allowed_image_formats: [ "jpg", "jpeg", "png", "gif", "webp" ],
          can_upload_images: true,
          can_generate_linkedin_bio: true
        },
        "ultimate" => {
          name: "Ultimate", # $49/month - AI Autopilot justifies premium pricing
          ai_generations_per_month: :unlimited,
          can_use_ai: true,
          can_edit_prompts: true,  # Full prompt customization
          can_add_content_modes: true,  # Can create custom modes
          available_content_modes: :all,
          available_platforms: :all,
          can_schedule_posts: true,
          can_use_analytics: true,
          can_white_label: false,  # Removed for simpler tier
          can_use_own_api_keys: true,  # Use their own AI API keys
          # Ultimate features
          can_use_ai_autopilot: true,  # AI automatically creates and schedules posts
          can_generate_platform_variants: true,  # Different content per platform
          can_use_interactive_ai_chat: true,  # Interactive content strategy conversations
          # AI Autopilot rate limits (prevent API spam)
          ai_autopilot_posts_per_day: 6,  # Max 6 auto-posts per day
          ai_autopilot_min_interval_hours: 2,  # Minimum 2 hours between auto-posts
          ai_autopilot_max_tokens_per_day: 5000,  # Token budget limit
          # Image upload limits
          max_image_size_mb: 50,
          max_images_per_post: 20,
          allowed_image_formats: [ "jpg", "jpeg", "png", "gif", "webp", "svg", "bmp", "tiff" ],
          can_upload_images: true,
          can_generate_linkedin_bio: true
        }
      }
    end

    # Check if user can access a feature
    def can_access_feature?(user, feature)
      tier = user.subscription_tier || "free"
      tier_config = feature_tiers[tier]

      return false unless tier_config

      tier_config[feature] == true || tier_config[feature] == :unlimited || tier_config[feature] == :all
    end

    # Get available content modes for user's tier
    def available_content_modes(user)
      tier = user.subscription_tier || "free"
      tier_config = feature_tiers[tier]

      return content_modes.keys if tier_config[:available_content_modes] == :all

      tier_config[:available_content_modes] || [ "business" ]
    end

    # Get available platforms for user's tier (now uses dynamic Platform model)
    def available_platforms(user)
      Platform.available_to_user(user).map(&:key)
    end
    # Content Mode Configurations (easily extensible)
    def content_modes
      {
        "business" => {
          name: "Business",
          description: "Professional & corporate tone",
          ai_role: "You are a professional business content creator specializing in authentic, value-driven social media posts. You help small business owners share their expertise and build trust with their audience without corporate buzzwords or salesy language.",
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
        "influencer" => {
          name: "Influencer",
          description: "Engaging & social media focused",
          ai_role: "You are a social media strategist helping influencers create engaging, authentic content that builds genuine connections with their audience while showcasing their unique personality and expertise.",
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
        "personal" => {
          name: "Personal",
          description: "Casual & authentic voice",
          ai_role: "You are helping create authentic personal social media content that feels genuine and relatable while maintaining professionalism appropriate for the person's career and interests.",
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
        "linkedin" => {
          name: "LinkedIn",
          char_limits: { min: 150, max: 3000, optimal: 300 },
          hashtag_count: { min: 2, max: 5 },
          style_hints: {
            tone: "Professional but authentic",
            focus: "Business insights and professional growth",
            engagement: "End with a thoughtful question"
          }
        },
        "facebook" => {
          name: "Facebook",
          char_limits: { min: 100, max: 63206, optimal: 250 },
          hashtag_count: { min: 1, max: 3 },
          style_hints: {
            tone: "Conversational and community-focused",
            focus: "Personal stories and community building",
            engagement: "Encourage discussion"
          }
        },
        "instagram" => {
          name: "Instagram",
          char_limits: { min: 50, max: 2200, optimal: 150 },
          hashtag_count: { min: 5, max: 30, optimal: 10 },
          style_hints: {
            tone: "Visual-friendly and catchy",
            focus: "Strong hook and visual complement",
            engagement: "Include call-to-action"
          }
        },
        "tiktok" => {
          name: "TikTok",
          char_limits: { min: 30, max: 2200, optimal: 100 },
          hashtag_count: { min: 3, max: 10 },
          style_hints: {
            tone: "Casual and trendy",
            focus: "Entertainment and quick tips",
            engagement: "Hook viewers immediately"
          }
        },
        "twitter" => {
          name: "Twitter/X",
          char_limits: { min: 10, max: 280, optimal: 200 },
          hashtag_count: { min: 1, max: 2 },
          style_hints: {
            tone: "Concise and punchy",
            focus: "Quick thoughts and hot takes",
            engagement: "Encourage retweets and replies"
          }
        },
        "youtube" => {
          name: "YouTube",
          char_limits: { min: 100, max: 5000, optimal: 500 },
          hashtag_count: { min: 3, max: 15 },
          style_hints: {
            tone: "Descriptive and keyword-rich",
            focus: "Video description and SEO",
            engagement: "Include links and timestamps"
          }
        },
        "general" => {
          name: "Multi-Platform",
          char_limits: { min: 100, max: 280, optimal: 200 },
          hashtag_count: { min: 2, max: 5 },
          style_hints: {
            tone: "Engaging and platform-neutral",
            focus: "Universal appeal and readability",
            engagement: "Works well across all platforms"
          }
        }
        # Easy to add new platforms
      }
    end

    # Get configuration for a specific content mode
    def get_content_mode(mode)
      content_modes[mode.to_s] || content_modes["business"] # Default to business
    end

    # Get configuration for a specific platform
    def get_platform(platform)
      platforms[platform.to_s.downcase] || {
        name: "General",
        char_limits: { min: 100, max: 500, optimal: 250 },
        hashtag_count: { min: 2, max: 5 },
        style_hints: {
          tone: "Engaging and authentic",
          focus: "Value and insights",
          engagement: "Encourage interaction"
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

    # Get image upload limits for user's tier
    def get_image_limits(user)
      tier = user.subscription_tier || "free"
      tier_config = feature_tiers[tier]

      {
        max_size_mb: tier_config[:max_image_size_mb],
        max_count: tier_config[:max_images_per_post],
        allowed_formats: tier_config[:allowed_image_formats],
        can_upload: tier_config[:can_upload_images]
      }
    end

    # Validate uploaded image against user's tier limits
    def validate_image_upload(user, file)
      limits = get_image_limits(user)

      errors = []

      # Check if user can upload images
      unless limits[:can_upload]
        return { valid: false, errors: [ "Image uploads not available in your plan" ] }
      end

      # Check file size
      size_mb = file.size.to_f / (1024 * 1024)
      if size_mb > limits[:max_size_mb]
        errors << "Image too large (#{size_mb.round(1)}MB). Maximum: #{limits[:max_size_mb]}MB"
      end

      # Check file format
      extension = File.extname(file.original_filename).downcase.delete(".")
      unless limits[:allowed_formats].include?(extension)
        errors << "Format '#{extension}' not supported. Allowed: #{limits[:allowed_formats].join(', ')}"
      end

      { valid: errors.empty?, errors: errors }
    end
  end
end
