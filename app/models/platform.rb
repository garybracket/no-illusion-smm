# Dynamic Platform Registry - Single source of truth for all platform data
class Platform
  include ActiveModel::Model

  attr_accessor :key, :name, :enabled, :oauth_implemented, :posting_implemented,
                :char_limits, :hashtag_limits, :image_specs, :content_style

  # Dynamic platform registry - easily add new platforms
  def self.registry
    @registry ||= {
      "linkedin" => new(
        key: "linkedin",
        name: "LinkedIn",
        enabled: true,
        oauth_implemented: true,
        posting_implemented: true,
        char_limits: { min: 150, max: 3000, optimal: 300 },
        hashtag_limits: { min: 2, max: 5 },
        image_specs: { max_size_mb: 25, max_count: 1, formats: %w[jpg jpeg png gif] },
        content_style: {
          tone: "Professional but authentic",
          focus: "Business insights and professional growth",
          engagement: "End with thoughtful questions",
          hashtag_style: "Professional industry tags"
        }
      ),
      "facebook" => new(
        key: "facebook",
        name: "Facebook",
        enabled: true,
        oauth_implemented: false, # TODO: Complete implementation
        posting_implemented: false,
        char_limits: { min: 100, max: 63206, optimal: 250 },
        hashtag_limits: { min: 1, max: 3 },
        image_specs: { max_size_mb: 25, max_count: 10, formats: %w[jpg jpeg png gif] },
        content_style: {
          tone: "Conversational and community-focused",
          focus: "Stories and community building",
          engagement: "Encourage discussion and shares",
          hashtag_style: "Broad community tags"
        }
      ),
      "instagram" => new(
        key: "instagram",
        name: "Instagram",
        enabled: true,
        oauth_implemented: false,
        posting_implemented: false,
        char_limits: { min: 50, max: 2200, optimal: 150 },
        hashtag_limits: { min: 5, max: 30, optimal: 10 },
        image_specs: { max_size_mb: 25, max_count: 10, formats: %w[jpg jpeg png] },
        content_style: {
          tone: "Visual-friendly and engaging",
          focus: "Strong hooks and visual storytelling",
          engagement: "Call-to-action and interaction prompts",
          hashtag_style: "Mix of niche and trending tags"
        }
      ),
      "tiktok" => new(
        key: "tiktok",
        name: "TikTok",
        enabled: true,
        oauth_implemented: false,
        posting_implemented: false,
        char_limits: { min: 30, max: 2200, optimal: 100 },
        hashtag_limits: { min: 3, max: 10 },
        image_specs: { max_size_mb: 25, max_count: 1, formats: %w[jpg jpeg png gif mp4] },
        content_style: {
          tone: "Casual, authentic, and trendy",
          focus: "Entertainment and quick tips",
          engagement: "Hook viewers in first 3 seconds",
          hashtag_style: "Trending and viral hashtags"
        }
      ),
      "youtube" => new(
        key: "youtube",
        name: "YouTube",
        enabled: true,
        oauth_implemented: false,
        posting_implemented: false,
        char_limits: { min: 100, max: 5000, optimal: 500 },
        hashtag_limits: { min: 3, max: 15 },
        image_specs: { max_size_mb: 25, max_count: 1, formats: %w[jpg jpeg png] },
        content_style: {
          tone: "Descriptive and keyword-rich",
          focus: "SEO optimization and discoverability",
          engagement: "Include timestamps and links",
          hashtag_style: "SEO-focused keyword tags"
        }
      ),
      "twitter" => new(
        key: "twitter",
        name: "Twitter/X",
        enabled: true,
        oauth_implemented: false,
        posting_implemented: false,
        char_limits: { min: 10, max: 280, optimal: 200 },
        hashtag_limits: { min: 1, max: 2 },
        image_specs: { max_size_mb: 5, max_count: 4, formats: %w[jpg jpeg png gif] },
        content_style: {
          tone: "Concise and punchy",
          focus: "Quick thoughts and commentary",
          engagement: "Encourage retweets and replies",
          hashtag_style: "Trending topics and keywords"
        }
      )
    }
  end

  # Get all platforms (for admin/config)
  def self.all
    registry.values
  end

  # Get enabled platforms only
  def self.enabled
    all.select(&:enabled)
  end

  # Get platforms with working OAuth
  def self.with_oauth
    all.select(&:oauth_implemented)
  end

  # Get platforms that can actually post
  def self.ready_for_posting
    all.select { |p| p.oauth_implemented && p.posting_implemented }
  end

  # Find platform by key
  def self.find(key)
    registry[key.to_s]
  end

  # Check if platform exists and is enabled
  def self.supported?(key)
    platform = find(key)
    platform&.enabled == true
  end

  # Get platforms available to user's tier
  def self.available_to_user(user)
    tier_config = AiConfigService.feature_tiers[user.subscription_tier || "free"]
    available_keys = tier_config[:available_platforms]

    if available_keys == :all
      ready_for_posting
    else
      ready_for_posting.select { |p| available_keys.include?(p.key) }
    end
  end

  # Dynamic content style hints for AI
  def ai_content_hints
    "CONTENT STYLE:\n" +
    "- #{content_style[:tone]}\n" +
    "- #{content_style[:focus]}\n" +
    "- #{content_style[:engagement]}\n" +
    "- Include #{hashtag_limits[:min]}-#{hashtag_limits[:max]} relevant hashtags\n" +
    "- Aim for #{char_limits[:optimal]} words (#{char_limits[:min]}-#{char_limits[:max]} range)"
  end

  # Check if user can upload images for this platform
  def supports_images?
    image_specs.present?
  end

  # Get image limits for user's tier
  def image_limits_for_user(user)
    tier_limits = AiConfigService.get_image_limits(user)

    {
      max_size_mb: [ tier_limits[:max_size_mb], image_specs[:max_size_mb] ].min,
      max_count: [ tier_limits[:max_count], image_specs[:max_count] ].min,
      allowed_formats: tier_limits[:allowed_formats] & image_specs[:formats]
    }
  end
end
