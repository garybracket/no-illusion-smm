# Social Media Manager - Architecture Documentation

## System Overview

**No iLLusion Social** is a privacy-first social media management platform that allows users to publish content across multiple platforms (Facebook, Instagram, LinkedIn, TikTok) with optional AI assistance and complete prompt transparency.

## Core Architecture Principles

### 1. **Privacy-First Design**
- Content processed in-memory only
- No content storage in database
- Auth0 handles user authentication (external to our database)
- Users control their own AI API keys

### 2. **Separation of Concerns**
- **Authentication**: Auth0 (user management, login/logout)
- **Database**: Supabase PostgreSQL (application data only)
- **AI Services**: Multiple providers with user-controlled API keys
- **Social APIs**: Direct platform integrations

### 3. **User Data Architecture**
- **No `users` table**: Auth0 is the source of truth for user identity
- **`profiles` table**: Application-specific user data linked by Auth0 `user_id` (sub claim)
- **Foreign key pattern**: All tables reference Auth0 `user_id` as TEXT field

## Database Architecture

### User Identity Pattern
```sql
-- Example table structure (all tables follow this pattern)
CREATE TABLE example_table (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL, -- Auth0 sub claim (e.g., "auth0|123456789")
    -- ... other fields
);
```

### Core Tables

#### **profiles** (User Application Data)
- Stores user preferences, skills, mission statement
- Links to Auth0 users via `user_id` field
- Contains AI preferences and provider configurations

#### **platform_connections** (Social Media Accounts)
- OAuth tokens for Facebook, Instagram, LinkedIn, TikTok
- Encrypted credential storage
- Per-platform settings and configuration

#### **posts** (Content Management)
- Metadata about published posts
- **No content storage** - content is processed and discarded
- Status tracking and platform routing

#### **post_analytics** (Performance Metrics)
- Social media engagement data
- Platform-specific metrics collection
- Performance tracking and insights

#### **ai_usage_tracking** (AI Monitoring)
- Token usage and cost tracking
- Provider performance monitoring
- Rate limit management

#### **prompt_templates** (Custom AI Prompts)
- User-created prompt templates
- System default templates
- Community sharing and ratings

### Data Flow

```
Auth0 User → profiles table → application features
     ↓
user_id (TEXT) used as foreign key in all tables
```

## Authentication Flow

### Auth0 Integration
1. **Login**: User authenticates with Auth0
2. **Session**: Auth0 provides JWT with `sub` claim
3. **Profile Creation**: First login creates profile record with `user_id = sub`
4. **Authorization**: All API calls verify Auth0 session

### No Local User Management
- Password resets, email verification: Auth0 handles
- User identity: Auth0 is authoritative source
- Application data: Stored in Supabase with Auth0 user_id reference

## AI System Architecture

### Multi-Provider Design
```
User Request → AI Provider Service → [OpenAI | Anthropic | Google]
                      ↓
              Intelligent Fallback Logic
                      ↓
              Response + Usage Tracking
```

### Prompt Template Integration
1. **Template Selection**: User/system/default template hierarchy
2. **Variable Substitution**: Dynamic user data insertion
3. **Content Generation**: AI provider API call
4. **Usage Logging**: Analytics and performance tracking

### Provider Fallback Logic
```javascript
// Priority-based provider selection
1. User's preferred provider (if available and under rate limit)
2. Secondary provider (if primary hits rate limit)
3. Tertiary provider (final fallback)
4. Built-in static content (if all AI providers fail)
```

## Content Publishing Architecture

### Privacy-First Processing
```
User Input → In-Memory Processing → Platform APIs → Immediate Flush
```

1. **Content Creation**: User creates content in UI
2. **AI Enhancement** (optional): Prompt templates + AI generation
3. **Platform Publishing**: Direct API calls to social platforms
4. **Memory Cleanup**: All content data discarded immediately
5. **Metadata Storage**: Only publishing status and analytics stored

### Platform Integration
- **Facebook/Instagram**: Graph API with Business API
- **LinkedIn**: API v2 with OAuth 2.0
- **TikTok**: Business API with video upload support
- **Error Handling**: Platform-specific error processing and retry logic

## Component Architecture

### Frontend (Next.js 15)
```
src/
├── app/
│   ├── (authenticated)/          # Protected routes
│   ├── api/                      # API endpoints
│   └── auth/                     # Auth0 routes
├── components/
│   ├── profile/                  # User settings
│   ├── prompts/                  # Template management
│   ├── tools/                    # Content creation
│   └── analytics/                # Metrics display
└── lib/                          # Services and utilities
```

### Backend Services
- **ai-provider-service.ts**: Multi-provider AI integration
- **post-publisher.ts**: Social media platform publishing
- **analytics-service.ts**: Metrics collection and processing
- **database.ts**: Supabase integration with Auth0 user mapping

## Security Architecture

### Authentication Security
- **Auth0 Session Management**: Industry-standard JWT handling
- **Route Protection**: Middleware on all authenticated routes
- **API Authorization**: Session verification on all API endpoints

### Data Security
- **No Content Persistence**: User content never stored
- **Encrypted Credentials**: Platform OAuth tokens encrypted
- **User API Keys**: Optional user-provided keys for AI services
- **CORS Configuration**: Restricted origins for API access

### Privacy Compliance
- **Minimal Data Collection**: Only essential metadata stored
- **User Control**: Users can delete all data
- **Transparent Processing**: Full visibility into AI prompts used
- **No Tracking**: No unnecessary analytics or user behavior tracking

## Deployment Architecture

### Production Environment
- **Frontend**: Vercel deployment with Next.js 15
- **Database**: Supabase PostgreSQL with connection pooling
- **Authentication**: Auth0 tenant with production domain
- **External APIs**: Direct integration with social platforms and AI providers

### Development Environment
- **Local Database**: SQLite with identical schema
- **Auth0 Development**: Separate tenant for testing
- **Environment Isolation**: Complete separation of dev/prod data

## Scaling Considerations

### Database Performance
- **Indexed Foreign Keys**: All `user_id` fields indexed
- **Query Optimization**: Efficient joins and filtering
- **Connection Pooling**: Supabase handles connection management

### AI Rate Limiting
- **Intelligent Cycling**: Automatic provider switching
- **Usage Tracking**: Real-time rate limit monitoring
- **User API Keys**: Distribute load across user-provided keys

### Content Processing
- **Stateless Design**: No session-dependent processing
- **Immediate Cleanup**: Memory-efficient content handling
- **Parallel Publishing**: Concurrent platform API calls

## Future Architecture Considerations

### Potential Enhancements
1. **Redis Caching**: For frequently accessed templates and settings
2. **Queue System**: For batch processing and scheduled posts
3. **CDN Integration**: For static assets and performance
4. **Monitoring**: Application performance and error tracking

### Backward Compatibility
- **Database Migrations**: Versioned schema changes
- **API Versioning**: Maintain compatibility for existing integrations
- **Auth0 Upgrades**: Maintain session compatibility across updates

## Development Workflow

### Database Changes
1. **Local Development**: SQLite schema updates
2. **Migration Creation**: Supabase migration files
3. **Testing**: Local validation of schema changes
4. **Production Deployment**: Manual SQL execution via Supabase Dashboard

### Code Deployment
1. **Development**: Local testing with Auth0 dev tenant
2. **Build Verification**: TypeScript compilation and linting
3. **Production Deploy**: Vercel automatic deployment from main branch
4. **Monitoring**: Post-deployment verification and error tracking

This architecture provides a solid foundation for privacy-first social media management with optional AI assistance, maintaining clear separation of concerns and user data control.