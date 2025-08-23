# Migration Plan: NextJS/Supabase → Ruby on Rails

## Project Overview

**From**: `social-media-manager` (NextJS 15 + Auth0 + Supabase + Vercel)
**To**: `no-illusion-smm` (Ruby on Rails + Heroku)

## Goals

1. **Simpler Architecture**: Full-stack Rails MVC instead of split frontend/backend
2. **Easier Deployment**: Single Heroku app vs multiple services
3. **Cleaner Database**: Rails migrations vs manual SQL
4. **Better Maintainability**: Rails conventions vs custom API structure
5. **Reference Preservation**: Keep original project for learning/comparison

## Tech Stack Comparison

### Current (NextJS/Supabase)
```
Frontend: NextJS 15 + TypeScript + Tailwind
Backend: NextJS API Routes
Database: Supabase PostgreSQL
Auth: Auth0
Deployment: Vercel + Supabase
```

### Target (Rails)
```
Frontend: Rails Views + Stimulus + Tailwind
Backend: Rails Controllers + Models
Database: PostgreSQL (Heroku Postgres)
Auth: Devise or Rails built-in auth
Deployment: Heroku (single app)
```

## Architecture Changes

### Authentication Strategy
**Current**: Auth0 external service
**New Options**:
1. **Devise** (recommended) - Rails standard authentication
2. **Rails built-in** - Simple email/password auth
3. **Omniauth** - Social login providers

**Decision**: Start with Devise for simplicity, add social auth later

### Database Architecture
**Current**: No users table (Auth0 user_id strings everywhere)
**New**: Proper Rails User model with associations

```ruby
# Proper Rails associations
class User < ApplicationRecord
  has_many :posts
  has_many :prompt_templates
  has_many :platform_connections
end

class Post < ApplicationRecord
  belongs_to :user
end
```

### AI Integration
**Current**: Complex multi-provider service with user API keys
**New**: Simplified service objects with same functionality

```ruby
# app/services/ai_content_service.rb
class AiContentService
  def initialize(user, provider = nil)
    @user = user
    @provider = provider || user.preferred_ai_provider
  end
  
  def generate_content(prompt_template, variables = {})
    # Same logic, cleaner Rails patterns
  end
end
```

## Feature Migration Priority

### Phase 1: Core Foundation (MVP)
1. **Rails App Setup**: New Rails 7.1 app with PostgreSQL
2. **User Authentication**: Devise setup
3. **Basic User Model**: Profile fields (name, email, bio)
4. **Single Platform**: Start with LinkedIn only
5. **Simple Posting**: Text-only posts without AI

### Phase 2: Essential Features
1. **Platform Connections**: OAuth for LinkedIn
2. **Post Management**: Create, edit, delete posts
3. **Basic Analytics**: Post performance tracking
4. **UI Enhancement**: Tailwind CSS styling

### Phase 3: AI Integration
1. **Prompt Templates**: Port existing prompt system
2. **AI Content Generation**: Single provider (OpenAI)
3. **Template Management**: CRUD operations

### Phase 4: Advanced Features
1. **Multi-Platform Support**: Facebook, Instagram, TikTok
2. **Multi-Provider AI**: Anthropic, Google
3. **Analytics Dashboard**: Charts and insights
4. **Community Features**: Template sharing

### Phase 5: Polish & Production
1. **Error Handling**: Comprehensive error management
2. **Testing**: RSpec test suite
3. **Performance**: Optimization and caching
4. **Monitoring**: Error tracking and performance monitoring

## Database Migration Strategy

### User-Centric Design
```ruby
# Instead of user_id strings everywhere, proper Rails associations

# Current (NextJS/Supabase)
CREATE TABLE posts (
  id UUID PRIMARY KEY,
  user_id TEXT NOT NULL, -- Auth0 sub claim
  content TEXT
);

# New (Rails)
class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.timestamps
    end
  end
end
```

### Core Models Migration

#### Users (NEW - proper Rails model)
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :posts, dependent: :destroy
  has_many :prompt_templates, dependent: :destroy
  has_many :platform_connections, dependent: :destroy
  
  # Profile fields from current system
  validates :name, presence: true
  enum content_mode: { business: 0, influencer: 1, personal: 2 }
end
```

#### Posts
```ruby
class Post < ApplicationRecord
  belongs_to :user
  
  validates :content, presence: true
  enum status: { draft: 0, scheduled: 1, published: 2, failed: 3 }
  enum content_mode: { business: 0, influencer: 1, personal: 2 }
end
```

#### PromptTemplates
```ruby
class PromptTemplate < ApplicationRecord
  belongs_to :user, optional: true # System templates have no user
  
  validates :name, :prompt_text, :content_mode, presence: true
  enum content_mode: { business: 0, influencer: 1, personal: 2, custom: 3 }
  
  scope :system_templates, -> { where(user: nil, is_system: true) }
  scope :public_templates, -> { where(is_public: true) }
end
```

#### PlatformConnections
```ruby
class PlatformConnection < ApplicationRecord
  belongs_to :user
  
  validates :platform_name, presence: true, 
            inclusion: { in: %w[linkedin facebook instagram tiktok] }
  validates :platform_name, uniqueness: { scope: :user_id }
  
  encrypts :access_token, :refresh_token
end
```

## Service Objects Migration

### AI Content Service
```ruby
# app/services/ai_content_service.rb
class AiContentService
  include HTTParty
  
  PROVIDERS = {
    openai: 'https://api.openai.com/v1/chat/completions',
    anthropic: 'https://api.anthropic.com/v1/messages'
  }.freeze
  
  def initialize(user, provider: :openai)
    @user = user
    @provider = provider
    @api_key = user.ai_api_key_for(provider) || Rails.application.credentials.dig(:ai, provider)
  end
  
  def generate_content(prompt_template, variables = {})
    resolved_prompt = resolve_template_variables(prompt_template, variables)
    
    case @provider
    when :openai
      generate_with_openai(resolved_prompt)
    when :anthropic
      generate_with_anthropic(resolved_prompt)
    end
  end
  
  private
  
  def resolve_template_variables(template, variables)
    content = template.prompt_text
    variables.each { |key, value| content.gsub!("{#{key}}", value.to_s) }
    content
  end
end
```

### Platform Publishing Service
```ruby
# app/services/platform_publishing_service.rb
class PlatformPublishingService
  def initialize(user, platform_name)
    @user = user
    @platform = user.platform_connections.find_by(platform_name: platform_name)
    raise "Platform not connected" unless @platform&.active?
  end
  
  def publish_post(content, options = {})
    case @platform.platform_name
    when 'linkedin'
      LinkedinPublisher.new(@platform).publish(content, options)
    when 'facebook'
      FacebookPublisher.new(@platform).publish(content, options)
    # etc.
    end
  end
end
```

## UI/UX Migration Strategy

### Rails Views vs React Components
**Current**: React components with TypeScript
**New**: Rails views with Stimulus controllers

```erb
<!-- app/views/posts/new.html.erb -->
<div class="max-w-2xl mx-auto p-6">
  <%= form_with model: @post, local: true, 
                data: { controller: "post-form", 
                        action: "ajax:success->post-form#handleSuccess" } do |f| %>
    
    <%= f.text_area :content, 
                     placeholder: "What would you like to share?",
                     class: "w-full p-4 border rounded-lg",
                     data: { post_form_target: "content" } %>
    
    <div class="flex items-center justify-between mt-4">
      <%= f.collection_check_boxes :platform_names, 
                                   current_user.platform_connections.active,
                                   :platform_name, :platform_name do |b| %>
        <div class="flex items-center">
          <%= b.check_box(class: "mr-2") %>
          <%= b.label(class: "capitalize") %>
        </div>
      <% end %>
      
      <%= f.submit "Publish", 
                   class: "bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700" %>
    </div>
  <% end %>
</div>
```

```javascript
// app/javascript/controllers/post_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "aiGenerate"]
  
  generateWithAI() {
    // Rails-specific AJAX calls instead of fetch
    Rails.ajax({
      url: "/ai/generate_content",
      type: "POST",
      data: new FormData(this.element),
      success: (response) => {
        this.contentTarget.value = response.content
      }
    })
  }
  
  handleSuccess(event) {
    // Handle successful post creation
    window.location.href = event.detail[0].redirect_url
  }
}
```

## Deployment Migration

### From Vercel/Supabase to Heroku
**Current**: 
- Frontend: Vercel
- Database: Supabase PostgreSQL
- Auth: Auth0 (external)

**New**:
- App: Heroku (Rails + PostgreSQL addon)
- Assets: Rails asset pipeline or Heroku
- Background Jobs: Sidekiq (if needed)

```bash
# Heroku setup
heroku create no-illusion-smm
heroku addons:create heroku-postgresql:essential-0
heroku addons:create heroku-redis:essential (for background jobs)

# Environment variables
heroku config:set RAILS_MASTER_KEY=xyz
heroku config:set OPENAI_API_KEY=xyz
heroku config:set LINKEDIN_CLIENT_ID=xyz
```

## Configuration Migration

### Environment Variables
```ruby
# config/credentials.yml.enc (Rails way)
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

### Database Configuration
```yaml
# config/database.yml
production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

## Migration Timeline

### Week 1: Foundation
- [ ] Rails app creation and basic setup
- [ ] User authentication with Devise
- [ ] Basic User model and profile
- [ ] Simple UI with Tailwind CSS

### Week 2: Core Features
- [ ] Post model and basic CRUD
- [ ] LinkedIn OAuth integration
- [ ] Simple posting functionality
- [ ] Basic error handling

### Week 3: AI Integration
- [ ] Prompt template models
- [ ] AI content generation service
- [ ] Template management UI
- [ ] OpenAI integration

### Week 4: Polish & Deploy
- [ ] UI/UX improvements
- [ ] Error handling and validation
- [ ] Heroku deployment setup
- [ ] Basic testing

## Risk Mitigation

### Technical Risks
1. **OAuth Complexity**: Start with one platform (LinkedIn)
2. **AI Integration**: Begin with single provider (OpenAI)
3. **UI Complexity**: Use Rails conventions, add JavaScript progressively

### Data Migration
- **No direct migration needed**: Fresh start with proper Rails architecture
- **Reference implementation**: Keep original project for feature reference
- **Gradual feature parity**: Build incrementally to match current functionality

## Success Metrics

### Technical
- [ ] Single command deployment (`git push heroku main`)
- [ ] Proper Rails associations and validations
- [ ] Clean MVC architecture
- [ ] Comprehensive test coverage

### Functional
- [ ] User authentication and profiles
- [ ] Social media posting (LinkedIn initially)
- [ ] AI content generation with templates
- [ ] Basic analytics and performance tracking

### Maintainability
- [ ] Rails conventions followed
- [ ] Clear service objects for external integrations
- [ ] Proper error handling and logging
- [ ] Documentation and code comments

## Next Steps

1. **Create Rails App**: `rails new no-illusion-smm`
2. **Set up Git Repository**: Initialize with proper `.gitignore`
3. **Plan Database Schema**: Start with User, Post, PromptTemplate models
4. **Choose Authentication**: Implement Devise
5. **Create MVP**: Single platform posting with basic UI

Ready to start building! 🚀