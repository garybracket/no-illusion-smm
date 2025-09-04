class Post < ApplicationRecord
  belongs_to :user

  # PRIVACY FIRST: JSON serialization for arrays but NO content storage
  serialize :platforms, coder: JSON
  # platform_post_ids is already a JSON column, no serialize needed

  # PRIVACY: No content validation - only metadata
  validates :content_length, presence: true, numericality: { greater_than: 0 }
  validates :content_hash, presence: true
  validates :platforms, presence: true

  # Enums
  enum status: { draft: 0, scheduled: 1, published: 2, failed: 3 }
  enum content_mode: { business: 0, influencer: 1, personal: 2 }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_platform, ->(platform) { where("platforms::jsonb ? ?", platform) }

  # PRIVACY: Virtual content attribute for forms - NEVER persisted
  attr_accessor :content

  # Set metadata when content is provided (for form processing only)
  def content=(new_content)
    @content = new_content
    if new_content.present?
      self.content_length = new_content.length
      self.content_hash = Digest::SHA256.hexdigest(new_content)[0..16] # Short hash for deduplication
    end
  end

  # Generate privacy-safe display for UI
  def display_content
    if content_length && content_length > 0
      "[#{content_length} character post#{' (AI Generated)' if ai_generated}]"
    else
      "[No content recorded]"
    end
  end

  # Check if post was actually published to platforms
  def published_to_platforms?
    platform_post_ids.present? && platform_post_ids.any?
  end

  # Callbacks
  before_validation :ensure_platforms_is_array

  private

  def ensure_platforms_is_array
    self.platforms = Array(platforms) unless platforms.is_a?(Array)
  end
end
