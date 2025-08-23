# Claude Context - No iLLusion SMM (Ruby on Rails)

## Project Overview
**No iLLusion SMM** - A Ruby on Rails **freemium SaaS platform** for social media management that helps users create and publish content across multiple platforms with optional AI assistance. Built with privacy, transparency, user empowerment, and **componentized feature control** at its core.

## Freemium Architecture
**Every feature is componentized and tier-gated:**
- **Free Tier**: Basic profile management, limited posts
- **Pro Tier**: LinkedIn sync, AI assistance, analytics  
- **Enterprise Tier**: Multi-platform, advanced AI, white-label

**Feature Control System**: All features can be enabled/disabled per user based on subscription tier.

## Branding Requirements
**MANDATORY**: This project MUST include a professional link to no-illusion.com with the exact text:
"Designed, created, and property of No iLLusion Software"

Must also include: "Made with ❤️" 
Both should be prominently placed in the footer.

## Company Mission & Values

### Enhanced Mission Statement
*"Unlike big corporations and consulting firms, we don't take advantage of people who don't understand technology. Built by someone who started as a teen fixing computers and spent 20+ years patiently helping non-tech users navigate technology, we provide honest social media tools that empower small business owners - not exploit them. We go the extra mile to explain, educate, and even help those who want to host their own infrastructure, because transparency and user empowerment always win over predatory practices."*

### Core Principles
- **No Games, No Gimmicks**: Transparent pricing and honest feature communication
- **Patient Education**: Bridge the gap between tech complexity and user understanding  
- **Anti-Predatory**: Fight against companies that exploit tech-ignorant small businesses
- **Function Over Form**: Build tools that work first, look pretty second
- **User Choice**: Optional AI assistance - users control their content creation approach
- **Self-Sufficient**: Single developer doing all work personally, using AI as a tool not replacement

## Current Status
**Milestone M1: Rails Foundation** 🚧 **IN PROGRESS**

### 🎯 **Migration from NextJS/Supabase System**

This project is a complete rebuild of the existing `social-media-manager` (NextJS + Auth0 + Supabase) into a cleaner Ruby on Rails full-stack application.

**Why the Migration:**
- **Simpler Architecture**: Rails MVC vs split frontend/backend
- **Easier Deployment**: Single Heroku app vs multiple services
- **Better Database Management**: Rails migrations vs manual SQL
- **Improved Maintainability**: Rails conventions vs custom patterns

## Tech Stack
- **Framework**: Ruby on Rails 7.1
- **Database**: PostgreSQL (Heroku Postgres)
- **Authentication**: Devise (instead of Auth0)
- **Frontend**: Rails Views + Stimulus + Tailwind CSS
- **Deployment**: Heroku (single app deployment)
- **Background Jobs**: Sidekiq (when needed)

## Database Schema (Rails Design)

### Core Models

#### User (Auth0 + Freemium)
```ruby
class User < ApplicationRecord
  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [:auth0]
  
  belongs_to :subscription_plan, optional: true
  has_many :posts, dependent: :destroy
  has_many :prompt_templates, dependent: :destroy
  has_many :platform_connections, dependent: :destroy
  has_many :feature_usages, dependent: :destroy
  
  validates :name, presence: true
  validates :auth0_id, uniqueness: true, allow_nil: true
  enum content_mode: { business: 0, influencer: 1, personal: 2 }
  
  # Freemium feature access
  def can_access_feature?(feature_name)
    subscription_plan&.has_feature?(feature_name) || false
  end
  
  def usage_remaining(feature_name)
    limit = subscription_plan&.feature_limit(feature_name)
    return 0 unless limit
    used = feature_usages.where(feature_name: feature_name, created_at: 1.month.ago..).count
    [limit - used, 0].max
  end
end
```

#### SubscriptionPlan (Freemium Tiers)
```ruby
class SubscriptionPlan < ApplicationRecord
  has_many :users
  
  validates :name, presence: true, uniqueness: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  def has_feature?(feature_name)
    features.include?(feature_name.to_s)
  end
  
  def feature_limit(feature_name)
    limits[feature_name.to_s]
  end
  
  # Default plans
  def self.free_plan
    find_by(name: 'Free') || create!(
      name: 'Free',
      price_cents: 0,
      features: ['basic_profile', 'manual_posts'],
      limits: { 'posts_per_month' => 5, 'platforms' => 1 }
    )
  end
  
  def self.pro_plan
    find_by(name: 'Pro') || create!(
      name: 'Pro', 
      price_cents: 1500, # $15/month
      features: ['basic_profile', 'manual_posts', 'linkedin_sync', 'ai_generation'],
      limits: { 'posts_per_month' => 100, 'platforms' => 2, 'ai_generations' => 50 }
    )
  end
end
```

#### FeatureUsage (Usage Tracking)
```ruby
class FeatureUsage < ApplicationRecord
  belongs_to :user
  
  validates :feature_name, presence: true
  validates :usage_count, presence: true, numericality: { greater_than: 0 }
  
  scope :current_month, -> { where(created_at: 1.month.ago..) }
  scope :for_feature, ->(feature) { where(feature_name: feature) }
end
```

#### Post
```ruby
class Post < ApplicationRecord
  belongs_to :user
  
  validates :content, presence: true
  enum status: { draft: 0, scheduled: 1, published: 2, failed: 3 }
  enum content_mode: { business: 0, influencer: 1, personal: 2 }
end
```

#### PromptTemplate
```ruby
class PromptTemplate < ApplicationRecord
  belongs_to :user, optional: true # System templates have no user
  
  validates :name, :prompt_text, :content_mode, presence: true
  enum content_mode: { business: 0, influencer: 1, personal: 2, custom: 3 }
  
  scope :system_templates, -> { where(user: nil, is_system: true) }
  scope :public_templates, -> { where(is_public: true) }
end
```

#### PlatformConnection
```ruby
class PlatformConnection < ApplicationRecord
  belongs_to :user
  
  validates :platform_name, presence: true, 
            inclusion: { in: %w[linkedin facebook instagram tiktok] }
  validates :platform_name, uniqueness: { scope: :user_id }
  
  encrypts :access_token, :refresh_token
end
```

## Architecture Improvements

### Rails Conventions vs Custom API
**Old (NextJS)**: Custom API routes with manual validation
**New (Rails)**: Standard Rails controllers with built-in validations

### Database Relationships
**Old (Supabase)**: user_id strings everywhere, no foreign keys
**New (Rails)**: Proper ActiveRecord associations and foreign keys

### Authentication
**Old (Auth0)**: External service, complex token management
**New (Devise)**: Built-in Rails authentication, simpler management

## Development Roadmap (Freemium SaaS Architecture)

### Phase 1: Foundation ✅ COMPLETE
- [x] Rails app setup with PostgreSQL
- [x] User authentication with Auth0
- [x] Basic User model and profile management
- [x] Tailwind CSS styling setup

### Phase 2: LinkedIn Integration (FIRST FEATURE)
- [ ] LinkedIn OAuth setup and authentication flow
- [ ] LinkedIn profile sync (bidirectional)
- [ ] Basic LinkedIn content publishing
- [ ] Profile data synchronization and updates

### Phase 3: Freemium Subscription System (CRITICAL INFRASTRUCTURE)
- [ ] User subscription model (Free/Pro/Enterprise)
- [ ] Feature gating system (componentized features)
- [ ] Stripe integration for payments
- [ ] Subscription management UI
- [ ] Feature access control middleware
- [ ] Usage limits and tracking per tier

### Phase 4: AI Integration (Pro Tier Feature) ✅ **COMPLETE**
- [x] Claude API content generation service
- [x] Intelligent prompt system based on user profile
- [x] Content mode support (business/influencer/personal)
- [x] Platform-specific optimization
- [x] Error handling and fallback content
- [x] REST API endpoints for AI features

### Phase 5: Multi-Platform Expansion (Enterprise Tier)
- [ ] Facebook/Instagram integration
- [ ] TikTok integration
- [ ] Multi-platform publishing
- [ ] Advanced analytics dashboard

### Phase 6: Advanced Features (Enterprise Tier)
- [ ] White-label options
- [ ] Team collaboration
- [ ] Advanced AI (multi-provider)
- [ ] Custom integrations

## Key Files (Rails Structure)

### Models
- `app/models/user.rb` - User authentication and profile
- `app/models/post.rb` - Social media posts
- `app/models/prompt_template.rb` - AI prompt templates
- `app/models/platform_connection.rb` - Social platform OAuth

### Controllers
- `app/controllers/application_controller.rb` - Base controller
- `app/controllers/posts_controller.rb` - Post management
- `app/controllers/prompt_templates_controller.rb` - Template CRUD
- `app/controllers/platform_connections_controller.rb` - OAuth management

### Services
- `app/services/ai_content_service.rb` - AI content generation
- `app/services/platform_publishing_service.rb` - Social media publishing
- `app/services/oauth_service.rb` - Platform authentication

### Views
- `app/views/layouts/application.html.erb` - Main layout
- `app/views/posts/` - Post management views
- `app/views/prompt_templates/` - Template management views
- `app/views/dashboard/` - Main dashboard

### JavaScript (Stimulus)
- `app/javascript/controllers/post_form_controller.js` - Post creation
- `app/javascript/controllers/ai_generation_controller.js` - AI features
- `app/javascript/controllers/platform_connection_controller.js` - OAuth flows

## Development Commands
- `bin/dev` - Start Rails server with Tailwind watch
- `rails db:create db:migrate` - Database setup
- `rails generate migration MigrationName` - Create migrations
- `rails console` - Rails console
- `rails test` - Run tests (when added)

## Deployment (Heroku)
```bash
# Create Heroku app
heroku create no-illusion-smm

# Add PostgreSQL
heroku addons:create heroku-postgresql:essential-0

# Set environment variables
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
heroku config:set RAILS_ENV=production

# Deploy
git push heroku main
heroku run rails db:migrate
```

## Environment Configuration

### Development
```yaml
# config/database.yml
development:
  adapter: postgresql
  encoding: unicode
  database: no_illusion_smm_development
  pool: 5
  username: postgres
  password: password
  host: localhost
```

### Production (Heroku)
```yaml
production:
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

### Credentials
```yaml
# config/credentials.yml.enc
ai:
  openai:
    api_key: xxx
  anthropic:
    api_key: xxx

linkedin:
  client_id: xxx
  client_secret: xxx

facebook:
  app_id: xxx
  app_secret: xxx
```

## Reference Implementation

The original `social-media-manager` project serves as a reference for:
- Feature requirements and user flows
- API integration patterns
- AI prompt template system design
- Database schema concepts (adapted for Rails)
- UI/UX patterns and components

## Current Limitations (To Be Implemented)
- **Single Platform**: Starting with LinkedIn only
- **Basic UI**: Minimal styling, will be enhanced
- **No AI Yet**: Will be added in Phase 3
- **No Analytics**: Will be added in Phase 5

## Privacy-First Architecture
- **No Content Storage**: Content processed and discarded immediately
- **User-Controlled AI**: Users provide their own API keys
- **Transparent Processing**: Full visibility into AI prompts used
- **Minimal Data Collection**: Only essential metadata stored

## Next Steps
1. Complete Rails app setup
2. Implement Devise authentication
3. Create basic User model with profile fields
4. Set up database migrations
5. Create simple dashboard and navigation

This Rails rebuild will provide a much cleaner, more maintainable codebase while preserving all the core functionality and privacy-first principles of the original system.