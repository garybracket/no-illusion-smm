class PostVariant < ApplicationRecord
  belongs_to :post

  validates :platform_key, presence: true
  validates :content_hash, presence: true
  validates :content_length, presence: true, numericality: { greater_than: 0 }

  # Virtual content attribute for forms - NEVER persisted (privacy-first)
  attr_accessor :content

  # Set metadata when content is provided
  def content=(new_content)
    @content = new_content
    if new_content.present?
      self.content_length = new_content.length
      self.content_hash = Digest::SHA256.hexdigest(new_content)[0..16]
      self.generated_at = Time.current
    end
  end

  # Get platform configuration dynamically
  def platform
    Platform.find(platform_key)
  end

  # Privacy-safe display for UI
  def display_content
    if platform && content_length
      "[#{content_length} character #{platform.name} post#{' (AI Generated)' if ai_tokens_used&.> 0}]"
    else
      "[No content recorded]"
    end
  end

  # Check if this variant was AI generated
  def ai_generated?
    ai_tokens_used.present? && ai_tokens_used > 0
  end
end
