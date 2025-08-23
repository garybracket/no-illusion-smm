class PromptTemplate < ApplicationRecord
  belongs_to :user, optional: true  # System templates have no user
  
  validates :name, :prompt_text, :content_mode, presence: true
  enum :content_mode, business: 0, influencer: 1, personal: 2, custom: 3
  
  scope :system_templates, -> { where(user: nil, is_system: true) }
  scope :public_templates, -> { where(is_public: true) }
end
