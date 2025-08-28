# Claude Context - No iLLusion SMM (Ruby on Rails)

## Project Overview
**No iLLusion SMM** - A Ruby on Rails freemium SaaS platform for social media management that helps users create and publish content across multiple platforms with optional AI assistance. Built with privacy, transparency, user empowerment, and componentized feature control at its core.

## 📊 CURRENT STATUS (Updated August 28, 2025)

### ✅ COMPLETED & WORKING
1. **Core Platform**: Full Rails 7.2 application with PostgreSQL
2. **Authentication**: Auth0 integration with user management
3. **LinkedIn Integration**: Complete OAuth flow and posting functionality
4. **AI Content Generation**: Multi-provider system (OpenAI, Anthropic, Google AI) with failover
5. **Freemium Subscription System**: 
   - 3 tiers (Free/Pro/Ultimate) with feature gating
   - Usage tracking and limits enforcement
   - AiConfigService for tier-based access control
6. **User Profile Management**: Content modes, skills, bio, settings
7. **Privacy Policy**: Updated with all current features and data collection
8. **AI Toggle Fix**: Buttons now properly hide when AI features disabled
9. **Database**: All migrations current, subscription_tiers table populated
10. **Complete Data Deletion System**: 
    - Facebook-compliant user data deletion functionality
    - Cascade deletion of all associated data (posts, connections, templates)
    - Audit logging and proper error handling
    - "Danger Zone" UI with confirmation dialog
    - Data deletion instructions page at `/data-deletion`

### 🚧 PARTIALLY COMPLETE - NEEDS FACEBOOK CREDENTIALS
**Facebook Integration (95% Complete)**:
- ✅ FacebookOauthController with proper OAuth flow
- ✅ FacebookApiService with posting and analytics
- ✅ UI integration in platform connections
- ✅ Routes configured
- ❌ **MISSING**: App ID and Secret from Facebook Developer Console
- ❌ **MISSING**: Production app review/approval for public use

**Next Steps for Facebook**:
1. Get App ID and Secret from [developers.facebook.com](https://developers.facebook.com)
2. Add to Rails credentials: `facebook: { app_id: 'xxx', app_secret: 'xxx' }`
3. Configure OAuth redirect URIs in Facebook app settings
4. Request permissions: `pages_manage_posts`, `pages_read_engagement`, `business_management`
5. Submit for app review to exit developer mode

### ⚠️ KNOWN ISSUES - NEEDS FUTURE WORK
1. **Dark Mode Not Working**: 
   - HTML has `class="dark"` but Tailwind v4 not generating dark mode classes
   - Manual CSS overrides added as temporary workaround
   - **ROOT CAUSE**: Tailwind v4.x compatibility issue with Rails asset pipeline
   - **SOLUTION**: Downgrade to Tailwind v3 or find v4-compatible configuration

2. **Light/Dark Toggle Never Worked**:
   - Theme toggle buttons exist but functionality broken
   - JavaScript theme controller present but ineffective
   - Currently disabled in production

### 🎯 READY FOR PRODUCTION DEPLOYMENT
**Core functionality is production-ready**:
- LinkedIn posting works perfectly
- AI content generation functional with all providers
- User authentication and management complete
- Subscription system operational
- Privacy policy updated and compliant

**Deployment blockers**: None for core features
**Optional enhancements**: Facebook integration, dark mode fixes

## 🎯 CRITICAL ARCHITECTURE REQUIREMENTS

### Freemium Model (MANDATORY - NEVER FORGET)
**EVERY feature must be componentized and tier-gated:**
- **Free Tier**: 10 AI posts/month, all platforms, 1 post/hour, 8MB images
- **Pro Tier ($8/mo)**: 100 AI posts, multi-platform variants, custom prompts, analytics
- **Ultimate Tier ($49/mo)**: Unlimited posts, AI Autopilot (6/day), own API keys, 50MB images

**Componentization Rules**:
1. EVERY new feature MUST have tier checks
2. ALL functionality MUST be toggle-able per subscription level
3. ALWAYS use `AiConfigService.can_access_feature?(user, :feature_name)`
4. NEVER hardcode features without tier gating
5. ALWAYS think "How does this fit in the freemium model?"

### 💡 Monetization & Growth Strategy
**Claude should proactively suggest monetization improvements:**
- Identify features that could be premium upsells
- Suggest A/B testing opportunities for pricing
- Recommend viral/referral program implementations
- Point out investor-attractive metrics to track
- Suggest features that increase user retention
- Recommend integrations that add value for enterprise

**Example suggestions Claude should make:**
- "Consider making bulk scheduling a Pro feature - it's high value"
- "Add usage analytics dashboard - investors love engagement metrics"
- "Implement referral system - 3 free months for successful referrals"
- "Track Monthly Recurring Revenue (MRR) prominently for investors"
- "Add team collaboration for Enterprise - higher price point justified"

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
**Production-Ready Freemium Platform** - Comprehensive tier system implemented

**Development Stage**: Full freemium architecture with multi-platform content system

## 🚀 **Current LinkedIn MVP (Working)**

### ✅ **Fully Functional**
- **Auth0 Authentication**: Sign up/sign in working perfectly
- **LinkedIn OAuth**: Connect LinkedIn accounts
- **LinkedIn Publishing**: Post directly to LinkedIn with tracking
- **AI Content Generation**: 3 modes with clean output, no wrapper text
- **Freemium System**: Complete tier-based feature gating
- **Multi-Platform Variants**: Different content for each platform (Pro/Ultimate)
- **AI Autopilot Architecture**: Ultimate tier with rate limiting
- **Content Mode Safeguards**: Custom prompts enhance, don't override
- **Professional Pricing Page**: Complete tier comparison
- **Profile Management**: User profiles with content modes
- **Resume Builder**: Basic LinkedIn profile import

### ⏳ **Still Needed for True Multi-Platform SMM**
- **Facebook/Instagram**: OAuth + posting APIs
- **TikTok**: Video content support + API integration  
- **YouTube**: Channel management + video descriptions
- **Twitter/X**: Threading support + API v2
- **Multi-platform scheduling**: Cross-platform post management
- **Analytics dashboard**: Performance tracking across platforms

### ✅ **Migration from NextJS/Supabase System - COMPLETED**

This project has successfully completed the migration from the existing `social-media-manager` (NextJS + Auth0 + Supabase) into a cleaner Ruby on Rails full-stack application.

**Why the Migration:**
- **Simpler Architecture**: Rails MVC vs split frontend/backend
- **Easier Deployment**: Single Heroku app vs multiple services
- **Better Database Management**: Rails migrations vs manual SQL
- **Improved Maintainability**: Rails conventions vs custom patterns

## Tech Stack
- **Framework**: Ruby on Rails 7.1
- **Database**: PostgreSQL (Heroku Postgres)  
- **Authentication**: Devise + Auth0 OAuth integration
- **Frontend**: Rails Views + Stimulus + Tailwind CSS
- **AI Integration**: Multiple AI content services
- **Background Jobs**: Sidekiq ready
- **Platform APIs**: LinkedIn, Facebook, Instagram, TikTok, YouTube ready
- **Email Services**: Resend integration for notifications
- **Deployment**: Heroku (single app deployment)

## ✅ Implemented Features

### Core System ✅ **COMPLETE**
- **User Management**: Complete Auth0 + Devise integration with user profiles
- **Authentication**: Direct Auth0 Universal Login (sign in/sign up working)
- **Profile Management**: Complete user profile editing with AI toggle
- **Platform Connections**: LinkedIn OAuth fully working
- **Posts System**: Content creation and publishing to LinkedIn
- **Resume Integration**: LinkedIn profile sync (basic data)

### AI Features ✅ **COMPLETE**  
- **AI Content Service**: Multi-provider AI content generation (Claude/OpenAI)
- **Generate with AI**: Create posts from prompts
- **Optimize Content**: Improve existing content for LinkedIn
- **Auto-Generate Posts**: Automatic content creation for scheduled jobs
- **AI Prompt Builder**: Dynamic prompt generation based on user profile

### LinkedIn Integration ✅ **WORKING**
- **LinkedIn OAuth**: Complete authentication flow
- **LinkedIn Publishing**: Direct posting to LinkedIn working
- **Profile Import**: Basic profile data sync (name, bio, summary)
- **Resume Generation**: Professional resume from LinkedIn data

#### LinkedIn API Limitations
**Current LinkedIn API v2 Restrictions:**
- ✅ **Available**: Basic profile (name, email, summary/bio)
- ❌ **Not Available**: Work experience, education, skills, contact details
- ❌ **Reason**: LinkedIn removed access to detailed profile data in API v2
- 🔧 **Workaround**: Manual resume import UI for work/education (planned)

### Database Models
- **User**: Auth0 integration, content modes, AI preferences, resume fields
- **PlatformConnection**: OAuth tokens for LinkedIn/Facebook/Instagram/TikTok/YouTube
- **Post**: Content management with status tracking and AI generation flags
- **PromptTemplate**: User-specific AI prompt templates

## Database Schema (Rails Design)

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

### Phase 1: Foundation ✅ **COMPLETE**
- [x] Rails app setup with PostgreSQL
- [x] User authentication with Auth0 (Direct Universal Login)
- [x] User profile management with content modes
- [x] Tailwind CSS responsive design
- [x] AI toggle functionality

### Phase 2: LinkedIn Integration ✅ **COMPLETE**
- [x] LinkedIn OAuth setup and authentication flow
- [x] LinkedIn profile sync (basic data import)
- [x] LinkedIn content publishing (working)
- [x] Profile data synchronization
- [x] Resume generation from LinkedIn data

### Phase 3: AI Integration ✅ **COMPLETE**
- [x] Claude API content generation service
- [x] Three AI generation modes:
  - [x] Generate with AI (manual prompts)
  - [x] Optimize Content (improve existing)
  - [x] Auto-Generate Posts (automatic for scheduling)
- [x] Intelligent prompt system based on user profile
- [x] Content mode support (business/influencer/personal)
- [x] Platform-specific optimization for LinkedIn
- [x] Error handling and fallback content

### Phase 4: Freemium Subscription System (NEXT PRIORITY)
- [ ] User subscription model (Free/Pro/Enterprise)
- [ ] Feature gating system (componentized features)
- [ ] Stripe integration for payments
- [ ] Subscription management UI
- [ ] Feature access control middleware
- [ ] Usage limits and tracking per tier

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

### Environment Variables
```bash
# .env file (development) / Heroku Config Vars (production)

# Auth0 Authentication
AUTH0_DOMAIN=dev-xjxc225muqx8ffbc.us.auth0.com
AUTH0_CLIENT_ID=xxx
AUTH0_CLIENT_SECRET=xxx
AUTH0_SECRET=xxx

# AI Providers
OPENAI_API_KEY=xxx
ANTHROPIC_API_KEY=xxx
GOOGLE_API_KEY=xxx

# Social Media Platform APIs  
FACEBOOK_APP_ID=981014477450029
FACEBOOK_APP_SECRET=8b528122dab4c647130df58ea6f66f72
LINKEDIN_CLIENT_ID=78681kh4iitymk
LINKEDIN_CLIENT_SECRET=xxx
TIKTOK_CLIENT_KEY=xxx
TIKTOK_CLIENT_SECRET=xxx
```

## Reference Implementation

The original `social-media-manager` project serves as a reference for:
- Feature requirements and user flows
- API integration patterns
- AI prompt template system design
- Database schema concepts (adapted for Rails)
- UI/UX patterns and components

## Future Enhancements

### Phase 1: Subscription System (Critical Path)
- **Stripe integration** - Payment processing, subscription management
- **Feature gating system** - Dynamic feature access based on subscription tier
- **Usage tracking** - Monitor feature usage, enforce limits
- **Billing dashboard** - User-friendly subscription management interface
- **Free trial system** - 14-day trial with full Pro features

### Phase 2: Multi-Platform Expansion
- **Facebook/Instagram** - Complete Meta platform integration
- **TikTok integration** - Video content management and publishing
- **Twitter/X support** - Thread management, scheduling
- **YouTube integration** - Video descriptions, community posts
- **Platform analytics** - Cross-platform performance insights

### Phase 3: Advanced AI Features
- **Multi-provider AI** - OpenAI, Anthropic, local models
- **Content optimization** - A/B testing, performance prediction
- **Brand voice training** - Consistent tone across all platforms
- **Visual content AI** - Image generation, video thumbnails
- **Content calendar AI** - Intelligent scheduling recommendations

### Phase 4: Enterprise & White-Label
- **Team collaboration** - Multiple users per account, role management
- **White-label platform** - Rebrandable solution for agencies
- **API access** - Third-party integrations, custom workflows
- **Advanced analytics** - ROI tracking, competitor analysis
- **Compliance tools** - Content approval workflows, audit trails

### Phase 5: Innovation Features
- **Mobile applications** - Native iOS/Android with offline support
- **Voice-to-content** - Speak ideas, AI converts to optimized posts
- **Video content tools** - Automated video creation, subtitle generation
- **Influencer marketplace** - Connect brands with content creators
- **Social listening** - Monitor brand mentions, competitor activity

## Privacy-First Architecture
- **No Content Storage** - Content processed and discarded immediately
- **User-Controlled AI** - Users provide their own API keys (Enterprise tier)
- **Transparent Processing** - Full visibility into AI prompts used
- **Minimal Data Collection** - Only essential metadata stored
- **GDPR Compliance** - Complete data control and export capabilities