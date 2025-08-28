class SubscriptionTier < ApplicationRecord
  has_many :users, foreign_key: 'subscription_tier', primary_key: 'slug'
  
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :billing_interval, inclusion: { in: %w[month year] }
  
  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(:sort_order, :id) }
  
  # Price in dollars
  def price_dollars
    price_cents / 100.0
  end
  
  # Check if tier has a specific feature
  def has_feature?(feature_key)
    features&.dig(feature_key.to_s) == true
  end
  
  # Get feature limit
  def feature_limit(feature_key)
    limits&.dig(feature_key.to_s)
  end
  
  # Get all features as hash
  def all_features
    features || {}
  end
  
  # Get all limits as hash  
  def all_limits
    limits || {}
  end
  
  # For Stripe integration
  def stripe_price_id
    "price_#{slug}_#{billing_interval}"
  end
end
