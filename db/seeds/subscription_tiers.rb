# Subscription Tiers Seed Data
# Run with: rails db:seed:replant SEED=subscription_tiers

puts "Creating subscription tiers with correct pricing..."

SubscriptionTier.destroy_all

# Free Tier - $0/month
free = SubscriptionTier.create!(
  name: 'Free',
  slug: 'free',
  price_cents: 0,
  billing_interval: 'month',
  description: 'Perfect for testing and individuals getting started',
  features: {
    can_use_ai: true,
    can_edit_prompts: false,
    can_generate_linkedin_bio: false,
    can_use_ai_autopilot: false,
    can_use_interactive_ai_chat: false
  },
  limits: {
    ai_generations_per_month: 10,
    posts_per_hour: 1,
    max_image_size_mb: 8,
    max_images_per_post: 1
  },
  is_active: true,
  sort_order: 1
)

# Pro Tier - $8/month
pro = SubscriptionTier.create!(
  name: 'Pro',
  slug: 'pro',
  price_cents: 800, # $8.00
  billing_interval: 'month',
  description: 'For growing businesses and influencers',
  features: {
    can_use_ai: true,
    can_edit_prompts: true,
    can_generate_linkedin_bio: true,
    can_use_ai_autopilot: false,
    can_use_interactive_ai_chat: false
  },
  limits: {
    ai_generations_per_month: 100,
    posts_per_hour: 5,
    max_image_size_mb: 15,
    max_images_per_post: 4
  },
  is_active: true,
  sort_order: 2
)

# Ultimate Tier - $49/month
ultimate = SubscriptionTier.create!(
  name: 'Ultimate',
  slug: 'ultimate',
  price_cents: 4900, # $49.00
  billing_interval: 'month',
  description: 'Full-featured solution with AI Autopilot and Interactive Chat',
  features: {
    can_use_ai: true,
    can_edit_prompts: true,
    can_generate_linkedin_bio: true,
    can_use_ai_autopilot: true,
    can_use_interactive_ai_chat: true
  },
  limits: {
    ai_generations_per_month: nil, # Unlimited
    ai_autopilot_posts_per_day: 6,
    max_image_size_mb: 50,
    max_images_per_post: 20
  },
  is_active: true,
  sort_order: 3
)

puts "✅ Created #{SubscriptionTier.count} subscription tiers:"
SubscriptionTier.ordered.each do |tier|
  puts "  - #{tier.name}: $#{tier.price_dollars}/#{tier.billing_interval}"
end
