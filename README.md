# No iLLusion SMM - Freemium SaaS Platform

**🎯 CRITICAL: Every feature MUST be componentized for subscription tiers**

A Ruby on Rails freemium SaaS platform for social media management with MANDATORY tier-gated features. Built with privacy, transparency, monetization, and user empowerment at its core.

## Project Status
✅ **LIVE IN PRODUCTION** - Complete Rails architecture with LinkedIn integration

**Live URL**: [https://smm.no-illusion.com](https://smm.no-illusion.com)

This is a complete rebuild of the existing `social-media-manager` (Next.js + Auth0 + Supabase) into a Ruby on Rails full-stack application. **Migration complete** - the Rails version has full LinkedIn integration, AI content generation, per-post content mode selection, and comprehensive profile management.

### Current Features (Phase 1-5 Complete)
- ✅ **Auth0 + Database Authentication**: Dual sign-in options
- ✅ **LinkedIn Integration**: Full OAuth, posting, profile sync
- ✅ **AI Content Generation**: Claude API with content mode optimization  
- ✅ **Per-Post Content Modes**: Business, Influencer, Personal selection
- ✅ **Profile Management**: Skills, experience, resume generation
- ✅ **Complete Data Deletion**: Facebook-compliant user data deletion system
- ✅ **Beta/Waitlist System**: Priority-scored signup system with admin dashboard
- ✅ **Email Configuration**: MXRoutes SMTP with professional noreply@no-illusion.com
- ✅ **Live Production Deployment**: Custom domain with SSL

## Core Values
- **No Games, No Gimmicks**: Transparent pricing and honest feature communication
- **Patient Education**: Bridge the gap between tech complexity and user understanding  
- **Anti-Predatory**: Fight against companies that exploit tech-ignorant small businesses
- **Function Over Form**: Build tools that work first, look pretty second
- **User Choice**: Optional AI assistance - users control their content creation approach

## 🎯 Freemium Architecture (MANDATORY FOR ALL FEATURES)

### Subscription Tiers (Componentized)
| Feature | Free | Pro ($8/mo) | Ultimate ($49/mo) |
|---------|------|-------------|------------------|
| AI Posts/Month | 10 | 100 | Unlimited |
| Posts Per Hour | 1 | 5 | Unlimited |
| Platforms | All | All | All |
| Custom AI Prompts | ❌ | ✅ | ✅ |
| Multi-Platform Variants | ❌ | ✅ | ✅ |
| Scheduling | ✅ | ✅ | ✅ |
| Analytics | ❌ | ✅ | ✅ |
| AI Autopilot | ❌ | ❌ | ✅ (6 posts/day) |
| Image Upload Size | 8MB | 15MB | 50MB |
| Images Per Post | 1 | 4 | 20 |
| Own API Keys | ❌ | ❌ | ✅ |

### Implementation Requirements
- **EVERY feature** must check tier with `AiConfigService.can_access_feature?(user, :feature)`
- **ALL new code** must include subscription checks
- **NEVER** implement features without tier gating
- **ALWAYS** think "What tier should access this?"

### 💰 Monetization Strategy (Claude Should Suggest)
- Premium feature identification opportunities
- A/B testing for pricing optimization
- Viral/referral program implementations
- Investor-attractive metrics (MRR, CAC, LTV)
- User retention features
- Enterprise value-adds

## Tech Stack
- **Framework**: Ruby on Rails 7.2.2
- **Database**: PostgreSQL (local development + Heroku Postgres)
- **Authentication**: Devise + Auth0 OAuth integration
- **Frontend**: Rails Views + Stimulus + Tailwind CSS 4
- **AI Integration**: Claude API for content generation
- **Platform APIs**: LinkedIn OAuth2, YouTube API (planned), Facebook Graph API (planned)
- **Deployment**: Heroku with custom domain (smm.no-illusion.com)
- **Background Jobs**: Sidekiq ready for scheduled posts

## Development Roadmap

### Phase 1: Foundation ✅ COMPLETE
- [x] Rails app setup with PostgreSQL
- [x] User authentication with Auth0 + Devise
- [x] Complete User model with content modes and AI preferences
- [x] Tailwind CSS styling setup with responsive design

### Phase 2: LinkedIn Integration ✅ **COMPLETE**
- [x] **Complete OAuth 2.0 Flow**: Secure LinkedIn authentication with CSRF protection
- [x] **Content Publishing**: Text + image posts to LinkedIn via UGC Posts API
- [x] **Profile Import**: LinkedIn profile data → app profile with smart mapping
- [x] **Profile Export**: App profile → formatted LinkedIn content for copy-paste
- [x] **Skills Intelligence**: AI-powered skills extraction from LinkedIn profiles
- [x] **Resume Builder**: Professional resume generation from LinkedIn data
- [x] **Connection Management**: Token refresh, expiration handling, status tracking
- [x] **Error Handling**: Comprehensive rate limiting, network, and API error management

### Phase 3: AI Content Generation ✅ **COMPLETE**  
- [x] **Claude API Integration**: Full AI content generation service
- [x] **Profile-Based Prompting**: User context and content mode optimization
- [x] **Content Modes**: Business, influencer, and personal content strategies
- [x] **Posts System**: Complete content creation and management framework
- [x] **Prompt Templates**: User-specific AI prompt management system
- [x] **AI Prompt Builder**: Dynamic prompt generation based on user data
- [x] **Multi-Provider Support**: Ready for OpenAI, Claude, and custom providers

### Phase 4: User Management & Authentication ✅ **COMPLETE**
- [x] **Devise + Auth0 Integration**: Secure user authentication and session management
- [x] **User Profiles**: Complete profile system with skills, bio, mission statement
- [x] **Platform Connections**: Multi-platform OAuth token storage and management
- [x] **Resume System**: LinkedIn-synced resume generation and management
- [x] **Content Mode Support**: Business/influencer/personal content preferences

### Phase 5: Freemium Infrastructure (IN PROGRESS) 🚧
- [x] **Database Structure**: SubscriptionTier model with proper pricing
- [x] **Feature Gating**: AiConfigService with comprehensive tier definitions  
- [x] **Tier Controls**: Free ($0), Pro ($8), Ultimate ($49) with proper restrictions
- [x] **Custom Prompts**: Pro/Ultimate only with content mode safeguards
- [x] **Multi-Platform Variants**: Pro/Ultimate feature for platform-specific content
- [x] **AI Autopilot Architecture**: Ultimate tier (6 posts/day, 2hr intervals, token budgets)
- [x] **Interactive AI Chat**: Ultimate tier feature (planned)
- [x] **Image Upload Limits**: Tier-based size and format restrictions
- [x] **Professional Pricing Page**: Three-tier comparison with correct pricing
- [x] **Dynamic Platform System**: Future-proof platform registry
- [x] **PostVariant Model**: Platform-specific content storage architecture
- [x] **Beta/Waitlist System**: Comprehensive beta signup system with priority scoring
- [ ] **Stripe Integration**: Payment processing and subscription management
- [ ] **Usage Tracking**: Real-time feature usage monitoring and limits enforcement
- [ ] **Subscription Management UI**: User upgrade/downgrade interface
- [ ] **Upgrade Prompts**: Smart prompts when users hit tier limits
- [ ] **Analytics Dashboard**: MRR/ARR tracking for business insights

### Phase 6: Multi-Platform Expansion (NEXT PRIORITY) 🎯
- [x] **Platform Architecture**: Dynamic registry system ready for any platform
- [x] **Content Variations**: Multi-platform content generation (Pro/Ultimate)
- [x] **LinkedIn Complete**: Full OAuth, posting, profile sync, bio generation
- [ ] **Facebook Integration**: OAuth + Pages API + posting (IN PROGRESS)
- [ ] **Instagram Integration**: OAuth + Basic Display API + posting
- [ ] **TikTok Integration**: OAuth + Content Posting API
- [ ] **YouTube Integration**: OAuth + Community Posts + video descriptions
- [ ] **Twitter/X Integration**: OAuth + API v2 + threading support
- [ ] **Cross-Platform Publishing**: Single post → multiple platforms simultaneously
- [ ] **Platform Analytics**: Performance tracking across all connected platforms

### Phase 7: Advanced Features (Ultimate Tier) 🔮
- [x] **AI Autopilot Architecture**: Complete system design with rate limiting
- [x] **Interactive AI Chat**: Feature planning and tier assignment
- [ ] **AI Autopilot Implementation**: Sidekiq background jobs for automated posting
- [ ] **Smart Rate Limiting**: API cost management and token budget enforcement
- [ ] **Background Job Monitoring**: Real-time job status and failure recovery
- [ ] **Advanced AI Customization**: Deep prompt engineering and model selection
- [ ] **Custom API Integrations**: User-defined webhooks and third-party connections
- [ ] **Team Collaboration**: Multi-user accounts with role management
- [ ] **White-Label Options**: Rebrandable platform for agencies
- [ ] **Enterprise Reporting**: Advanced analytics and ROI tracking

## LinkedIn Integration Features

### 🔐 OAuth Authentication & Security
- **Secure OAuth 2.0 flow** with CSRF protection via state parameters
- **Token management** with automatic expiration handling
- **Connection validation** before all API operations
- **Rate limiting compliance** with LinkedIn API limits
- **Error recovery** for expired tokens and network issues

### 📱 Content Publishing
- **LinkedIn Post Creation** via UGC Posts API with LinkedIn v2
- **Text + Image Support** with custom titles and descriptions
- **Public visibility** by default with configurable options
- **Success tracking** with LinkedIn post URLs for published content
- **Comprehensive error handling** with user-friendly messages

### 👤 Profile Integration
- **Profile Import**: LinkedIn → App profile data synchronization
  - Name, headline, summary, work history, education, profile picture
  - Skills extraction with intelligent business/technical categorization
  - Automatic profile enhancement on OAuth connection
- **Profile Export**: App → LinkedIn formatted content for copy-paste
  - Professional headline generation from mission statements
  - Formatted "About" section with skills and expertise
  - Experience templates based on user skills
  - Copy-to-clipboard functionality for easy LinkedIn updates

### 📄 Resume Builder
- **LinkedIn-Synced Resume Generation** with professional formatting
- **Auto-import work history** and education from LinkedIn profiles
- **Skills integration** with categorization (technical/business)
- **Mission statement incorporation** for professional branding
- **Resume preview and download** functionality

### 🔧 Technical Architecture
- **Service-based design** with clear separation of concerns
- **PlatformConnection model** with encrypted token storage
- **User helpers** for connection status (`linkedin_connected?`)
- **Comprehensive logging** for debugging and monitoring
- **Rails conventions** with proper validations and associations

## Key Models

### User (Auth0 + Profile Management)
- **Authentication**: Devise + Auth0 integration with secure user management
- **Profile System**: Bio, mission statement, skills, content modes
- **LinkedIn Integration**: Connection helpers and status tracking
- **AI Preferences**: Content mode support (business/influencer/personal)
- **Resume Fields**: LinkedIn-synced professional information

### PlatformConnection (Multi-Platform OAuth)
- **Secure Token Storage**: Rails encryption for access/refresh tokens
- **Platform Support**: LinkedIn (complete), Facebook/Instagram/TikTok/YouTube (ready)
- **Connection Validation**: Expiration checking and status management
- **Settings Storage**: Platform-specific configuration as JSON

### Post (Content Management)
- **Content Creation**: AI-assisted post generation with multiple modes
- **Publishing Status**: Draft, scheduled, published, failed tracking
- **Platform Integration**: Multi-platform publishing support
- **AI Generation Flags**: Track AI-generated vs manual content

### LinkedIn Services
- **LinkedinApiService**: Core API communication with rate limiting
- **LinkedinProfileImportService**: Profile data import with smart mapping
- **LinkedinProfileExportService**: Formatted profile export for manual updates
- **LinkedinOauthController**: Complete OAuth flow management

## Development Commands
```bash
# Start development server with Tailwind watching
bin/dev

# Database setup
rails db:create db:migrate db:seed

# Rails console
rails console

# Run tests
rails test

# Generate migrations
rails generate migration MigrationName
```

## Beta/Waitlist System Features

### 🎯 Priority-Based Signup System
- **Smart Priority Scoring**: Automatic scoring based on company size, platforms, engagement level
- **Admin Dashboard**: Complete management interface for beta testers at `/beta_signups`
- **Status Management**: Pending → Accepted → Invited → Active workflow
- **Professional Coming Soon Page**: Company branding with comprehensive signup form
- **Email Integration**: Ready for beta invitation and onboarding emails

### 📊 Admin Management Features
- **Stats Dashboard**: Total signups, weekly/monthly metrics, status breakdown
- **Priority Sorting**: High/Medium/Low priority automatic classification
- **Bulk Actions**: Accept/reject multiple applicants (planned)
- **Export Functionality**: CSV export of beta signups (planned)
- **Email Templates**: Professional beta invitation emails (planned)

### 🔐 Security & Access Control
- **Admin-Only Access**: Only real.ener.g@gmail.com can access beta dashboard
- **CSRF Protection**: All form submissions secured
- **Input Validation**: Professional form validation with proper error handling
- **Spam Prevention**: Rate limiting and honeypot fields (planned)

## Environment Configuration

### Development
```yaml
# config/database.yml
development:
  adapter: postgresql
  encoding: unicode
  database: no_illusion_smm_development
  pool: 5
  username: gary
  password: key$1234
  host: localhost
```

### Credentials
```yaml
# config/credentials.yml.enc
ai:
  anthropic:
    api_key: your_claude_api_key

auth0:
  domain: your_auth0_domain
  client_id: your_client_id
  client_secret: your_client_secret

linkedin:
  client_id: your_linkedin_client_id
  client_secret: your_linkedin_client_secret
```

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

## Reference Implementation
The original `social-media-manager` project serves as a reference for:
- Feature requirements and user flows
- API integration patterns
- AI prompt template system design
- Database schema concepts (adapted for Rails)
- UI/UX patterns and components

## Current Status
- **✅ Complete LinkedIn Integration**: Full OAuth, posting, profile sync, resume builder
- **✅ AI Content Generation**: Claude API with clean output, no wrapper text or platform mentions
- **✅ User Management**: Auth0 + Devise dual authentication, complete profile system
- **✅ Content Management**: Posts creation with AI assistance (Generate/Optimize/Auto-Generate)
- **✅ Resume System**: LinkedIn-synced professional resume generation
- **✅ Freemium Architecture**: Comprehensive tier system (Free/Pro/Ultimate)
- **✅ Multi-Platform System**: Dynamic platform registry for future-proofing
- **✅ Content Mode Safeguards**: Custom prompts enhance but cannot override base modes
- **✅ Professional Pricing Page**: Three-tier comparison with all features
- **✅ AI Autopilot Design**: Ultimate tier with 6 posts/day, 2-hour intervals, token budgets
- **✅ Beta/Waitlist System**: Priority-based signup system with admin management dashboard
- **✅ Email Infrastructure**: MXRoutes SMTP configuration with professional email handling
- **🚧 Next**: Facebook integration testing and Stripe payment processing

## Privacy-First Architecture
- **No Content Storage**: Content processed and discarded immediately
- **User-Controlled AI**: Users provide their own API keys
- **Transparent Processing**: Full visibility into AI prompts used
- **Minimal Data Collection**: Only essential metadata stored

## License
MIT License - see LICENSE file for details.

---

Made with ❤️  
[Designed, created, and property of No iLLusion Software](https://no-illusion.com)