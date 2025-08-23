class User < ApplicationRecord
  # SECURE AUTH0 + DEVISE CONFIGURATION
  # Remove password authentication - Auth0 handles this securely
  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [:auth0]
  
  # SECURITY: Auth0 user identifier - this is our source of truth for authenticated users
  validates :auth0_id, uniqueness: true, allow_nil: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Associations
  has_many :posts, dependent: :destroy
  has_many :prompt_templates, dependent: :destroy
  has_many :platform_connections, dependent: :destroy
  
  # LinkedIn integration helpers
  def linkedin_connection
    platform_connections.for_platform('linkedin').active.first
  end
  
  def linkedin_connected?
    linkedin_connection&.valid_connection? || false
  end

  # Validations
  validates :name, presence: true
  validates :content_mode, presence: true

  # Enums (Rails 8.0 compatible syntax)
  enum :content_mode, business: 0, influencer: 1, personal: 2

  # Callbacks
  before_create :set_default_ai_preferences

  # SECURE AUTH0 INTEGRATION - This is called when user authenticates via Auth0
  def self.from_omniauth(auth)
    # SECURITY: Validate Auth0 response structure
    # Handle both omniauth objects and test hashes
    info = auth.respond_to?(:info) ? auth.info : auth['info']
    uid = auth.respond_to?(:uid) ? auth.uid : auth['uid']
    
    return nil unless info&.[]('email') && uid
    
    # Find or create user by Auth0 ID (most secure approach)
    user = find_by(auth0_id: uid) || find_by(email: info['email'])
    
    if user
      # Update Auth0 ID if user was found by email (for existing users)
      user.update!(auth0_id: uid) if user.auth0_id != uid
    else
      # SECURITY: Create new user with required validations
      user = create!(
        auth0_id: uid,
        email: info['email'],
        name: info['name'] || info['email'].split('@').first,
        content_mode: :business  # Safe default
      )
    end
    
    user
  rescue ActiveRecord::RecordInvalid => e
    # SECURITY: Log authentication failures for monitoring
    Rails.logger.error "Auth0 user creation failed: #{e.message}"
    nil
  end

  private

  def set_default_ai_preferences
    return unless self.ai_preferences.blank?
    
    self.ai_preferences = {
      "generation" => true,
      "suggestions" => true,
      "optimization" => true,
      "providers" => {
        "openai" => { "enabled" => true, "api_key" => nil, "priority" => 1 },
        "anthropic" => { "enabled" => false, "api_key" => nil, "priority" => 2 },
        "google" => { "enabled" => false, "api_key" => nil, "priority" => 3 }
      },
      "fallback_cycling" => true,
      "rate_limit_buffer" => 0.1
    }
  end
end
