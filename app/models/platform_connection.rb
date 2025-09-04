class PlatformConnection < ApplicationRecord
  belongs_to :user

  # Security: Encrypt sensitive tokens (disabled for testing)
  # encrypts :access_token, :refresh_token

  # Validations
  validates :platform_name, presence: true,
            inclusion: { in: %w[linkedin facebook instagram tiktok youtube] }
  validates :platform_name, uniqueness: { scope: [ :user_id, :platform_user_id ] }
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

  # Platform specific helpers
  def linkedin?
    platform_name == "linkedin"
  end

  def facebook?
    platform_name == "facebook"
  end

  # Facebook page display name
  def facebook_page_name
    return nil unless facebook?
    settings["page_name"] || "Facebook Page (#{platform_user_id})"
  end
end
