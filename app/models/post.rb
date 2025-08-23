class Post < ApplicationRecord
  belongs_to :user
  
  # Serialize platforms as array
  serialize :platforms, coder: JSON
  
  validates :content, presence: true
  validates :platforms, presence: true
  
  # Enums
  enum :status, draft: 0, scheduled: 1, published: 2, failed: 3
  enum :content_mode, business: 0, influencer: 1, personal: 2
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_platform, ->(platform) { where("platforms::jsonb ? ?", platform) }
  
  # Callbacks
  before_validation :ensure_platforms_is_array
  
  private
  
  def ensure_platforms_is_array
    self.platforms = Array(platforms) unless platforms.is_a?(Array)
  end
end
