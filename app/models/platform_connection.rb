class PlatformConnection < ApplicationRecord
  belongs_to :user
  
  # Security: Encrypt sensitive tokens (disabled for testing)
  # encrypts :access_token, :refresh_token
  
  # Validations
  validates :platform_name, presence: true, 
            inclusion: { in: %w[linkedin facebook instagram tiktok] }
  validates :platform_name, uniqueness: { scope: :user_id }
  validates :access_token, presence: true
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :for_platform, ->(platform) { where(platform_name: platform) }
  
  # Check if token is expired
  def expired?
    expires_at && expires_at < Time.current
  end
  
  # Check if connection is valid
  def valid_connection?
    is_active? && !expired? && access_token.present?
  end
  
  # LinkedIn specific helper
  def linkedin?
    platform_name == 'linkedin'
  end
end
