# No iLLusion SMM (Rails)

A Ruby on Rails freemium SaaS platform for social media management that helps users create and publish content across multiple platforms with optional AI assistance. Built with privacy, transparency, and user empowerment at its core.

## Project Status
🚧 **Active Development** - Migration from Next.js/Supabase to Rails architecture

This is a complete rebuild of the existing `social-media-manager` (Next.js + Auth0 + Supabase) into a cleaner Ruby on Rails full-stack application for better maintainability and deployment simplicity.

## Core Values
- **No Games, No Gimmicks**: Transparent pricing and honest feature communication
- **Patient Education**: Bridge the gap between tech complexity and user understanding  
- **Anti-Predatory**: Fight against companies that exploit tech-ignorant small businesses
- **Function Over Form**: Build tools that work first, look pretty second
- **User Choice**: Optional AI assistance - users control their content creation approach

## Freemium Architecture
**Every feature is componentized and tier-gated:**
- **Free Tier**: Basic profile management, limited posts
- **Pro Tier**: LinkedIn sync, AI assistance, analytics  
- **Enterprise Tier**: Multi-platform, advanced AI, white-label

## Tech Stack
- **Framework**: Ruby on Rails 7.1
- **Database**: PostgreSQL (Heroku Postgres)
- **Authentication**: Devise + Auth0 integration
- **Frontend**: Rails Views + Stimulus + Tailwind CSS
- **AI Integration**: Claude API for content generation
- **Deployment**: Heroku (single app deployment)
- **Background Jobs**: Sidekiq (when needed)

## Development Roadmap

### Phase 1: Foundation ✅ COMPLETE
- [x] Rails app setup with PostgreSQL
- [x] User authentication with Auth0
- [x] Basic User model and profile management
- [x] Tailwind CSS styling setup

### Phase 2: Profile Management Integration (CRITICAL)
- [ ] **Profile System Integration**: Replace database user model with JSON profile system
- [ ] **Admin Profile Interface**: Complete profile management UI for editing user settings
- [ ] **Profile Service**: Service layer for reading/writing profile JSON files
- [ ] **User Profile Migration**: Migrate existing user data to JSON profile format
- [ ] **Guardrail Testing**: Admin can impersonate users and test profile settings

### Phase 3: LinkedIn Integration (FIRST BUSINESS FEATURE)
- [ ] LinkedIn OAuth setup and authentication flow
- [ ] LinkedIn profile sync (bidirectional)
- [ ] Basic LinkedIn content publishing
- [ ] Profile data synchronization and updates

### Phase 4: Freemium Subscription System (CRITICAL INFRASTRUCTURE)
- [ ] User subscription model (Free/Pro/Enterprise)
- [ ] Feature gating system (componentized features)
- [ ] Stripe integration for payments
- [ ] Subscription management UI
- [ ] Feature access control middleware
- [ ] Usage limits and tracking per tier

### Phase 5: AI Integration (Pro Tier Feature) ✅ **COMPLETE**
- [x] Claude API content generation service
- [x] Intelligent prompt system based on user profile
- [x] Content mode support (business/influencer/personal)
- [x] Platform-specific optimization
- [x] Error handling and fallback content
- [x] REST API endpoints for AI features

### Phase 6: Multi-Platform Expansion (Enterprise Tier)
- [ ] Facebook/Instagram integration
- [ ] TikTok integration
- [ ] Multi-platform publishing
- [ ] Advanced analytics dashboard

### Phase 7: Advanced Features (Enterprise Tier)
- [ ] White-label options
- [ ] Team collaboration
- [ ] Advanced AI (multi-provider)
- [ ] Custom integrations

## Key Models

### User (Auth0 + Freemium)
- Authentication via Devise + Auth0 integration
- Freemium tier management with feature access control
- Profile management with content mode support
- Usage tracking and limits per subscription tier

### Post Management
- Content creation with AI assistance
- Multi-platform publishing
- Status tracking (draft, scheduled, published, failed)
- Content mode support (business/influencer/personal)

### Platform Connections
- OAuth integration for social platforms
- Secure token storage with Rails encryption
- Platform-specific settings and configurations
- Connection status tracking

### AI Content Service
- Claude API integration for content generation
- User profile-based prompting
- Content mode optimization
- Error handling with fallback content

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
- **Single Platform**: Starting with LinkedIn only
- **Basic Rails Architecture**: Models, controllers, and views established
- **AI Integration**: Claude API service implemented
- **Profile Management**: User profiles with content modes
- **Authentication**: Devise setup with Auth0 preparation

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