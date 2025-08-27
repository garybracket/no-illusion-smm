# Setup Guide

## Prerequisites

Before starting, ensure you have:

- **Node.js 18+** and npm installed
- **Auth0 account** (free tier available)
- **Supabase account** (free tier available)
- **OpenAI API key** (optional, for AI features)
- **Git** for version control

## 1. Project Setup

### Clone and Install Dependencies

```bash
git clone <repository-url>
cd social-media-manager
npm install
```

### Environment Configuration

Create your environment file:
```bash
cp .env.example .env.local
```

## 2. Auth0 Configuration

**Note**: This project uses Auth0 Next.js SDK v4.9.0 with centralized client implementation.

### Create Auth0 Application

1. Go to [Auth0 Dashboard](https://manage.auth0.com/)
2. Click "Create Application"
3. Choose "Regular Web Application"
4. Note your **Domain**, **Client ID**, and **Client Secret**

### Configure Application Settings

In your Auth0 application settings:

**Allowed Callback URLs:**
```
http://localhost:3000/auth/callback
```

**Allowed Logout URLs:**
```
http://localhost:3000
```

**Allowed Web Origins:**
```
http://localhost:3000
```

### Enable Social Connections (Optional)

1. Go to **Authentication > Social** in Auth0 dashboard
2. Enable **Google** connection
3. Configure with your Google OAuth credentials

### Update Environment Variables

Add to `.env.local`:
```env
# Auth0 v4 Configuration
AUTH0_SECRET=your-32-byte-random-secret-here
AUTH0_DOMAIN=your-domain.auth0.com
APP_BASE_URL=http://localhost:3000
AUTH0_CLIENT_ID=your_auth0_client_id
AUTH0_CLIENT_SECRET=your_auth0_client_secret
```

**Important v4 Changes:**
- `AUTH0_BASE_URL` → `APP_BASE_URL`
- `AUTH0_ISSUER_BASE_URL` → `AUTH0_DOMAIN` (without https://)

**Generate AUTH0_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## 3. Supabase Database Setup

### Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Wait for setup to complete
4. Go to **Settings > API** and note:
   - Project URL
   - Anon public key
   - Service role key

### Set Up Database Schema

1. Go to **SQL Editor** in Supabase dashboard
2. Run the following SQL to create the schema:

```sql
-- Use the complete schema from supabase-schema.sql
-- This includes all tables: profiles, platform_connections, posts, post_logs, 
-- notifications, post_analytics, ai_usage_tracking, ai_rate_limits

-- Create profiles table (using Auth0 user IDs as strings)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL, -- Auth0 user ID (sub claim)
    email TEXT,
    name TEXT,
    bio TEXT,
    skills TEXT[] DEFAULT '{}',
    mission_statement TEXT, -- User's business mission statement
    content_mode TEXT DEFAULT 'business' CHECK (content_mode IN ('business', 'influencer', 'personal')),
    ai_enabled BOOLEAN DEFAULT true,
    ai_preferences JSONB DEFAULT '{
        "generation": true,
        "suggestions": true,
        "optimization": true,
        "providers": {
            "openai": {"enabled": true, "api_key": null, "priority": 1},
            "anthropic": {"enabled": false, "api_key": null, "priority": 2},
            "google": {"enabled": false, "api_key": null, "priority": 3}
        },
        "fallback_cycling": true,
        "rate_limit_buffer": 0.1
    }',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id)
);

-- Create platform_connections table for Facebook, Instagram, LinkedIn, TikTok
CREATE TABLE IF NOT EXISTS platform_connections (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL, -- Auth0 user ID (sub claim)
    platform_name TEXT NOT NULL CHECK (platform_name IN ('facebook', 'instagram', 'linkedin', 'tiktok')),
    access_token TEXT NOT NULL,
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, platform_name)
);

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL, -- Auth0 user ID (sub claim)
    content TEXT NOT NULL,
    image_url TEXT,
    platforms TEXT[] DEFAULT '{}',
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'posted', 'failed')),
    content_mode TEXT CHECK (content_mode IN ('business', 'influencer', 'personal')),
    ai_generated BOOLEAN DEFAULT false,
    scheduled_for TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- See supabase-schema.sql for complete schema including:
-- post_logs, notifications, post_analytics, ai_usage_tracking, ai_rate_limits tables
-- Run the complete schema file in your Supabase SQL Editor
```

### Update Environment Variables

Add to `.env.local`:
```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

## 4. Social Media Platform Setup

### Facebook & Instagram API Setup

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use existing one
3. Add "Facebook Login" product
4. Configure OAuth redirect URI: `http://localhost:3000/api/auth/facebook`
5. Get App ID and App Secret

### LinkedIn API Setup

1. Go to [LinkedIn Developer](https://developer.linkedin.com/)
2. Create a new app
3. Add OAuth 2.0 redirect URI: `http://localhost:3000/api/auth/linkedin`
4. Request permissions: `openid`, `profile`, `email`, `w_member_social`
5. Get Client ID and Client Secret

### TikTok for Business API Setup

1. Go to [TikTok for Developers](https://developers.tiktok.com/)
2. Create a new app in TikTok for Business
3. Configure OAuth redirect URI: `http://localhost:3000/api/auth/tiktok`
4. Request scopes: `user.info.basic`, `video.publish`
5. Get Client Key and Client Secret

### Update Environment Variables

Add to `.env.local`:
```env
# Social Media Platform APIs
FACEBOOK_APP_ID=your_facebook_app_id_here
FACEBOOK_APP_SECRET=your_facebook_app_secret_here
LINKEDIN_CLIENT_ID=your_linkedin_client_id_here
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret_here
TIKTOK_CLIENT_KEY=your_tiktok_client_key_here
TIKTOK_CLIENT_SECRET=your_tiktok_client_secret_here
```

## 5. Optional: AI Configuration

For multi-provider AI content generation:

### OpenAI API Key

1. Go to [platform.openai.com](https://platform.openai.com)
2. Create API key

### Anthropic Claude API Key

1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Create API key

### Google Gemini API Key

1. Go to [ai.google.dev](https://ai.google.dev)
2. Create API key

### Update Environment Variables

Add to `.env.local`:
```env
# AI Services (Global Fallback - Users can configure their own keys in profile)
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
GOOGLE_API_KEY=your_google_gemini_api_key_here
```

**Note:** AI features will work with fallback content if no API keys are provided.

## 6. Start Development

### Run the Application

```bash
npm run dev
```

The application will be available at [http://localhost:3000](http://localhost:3000)

### Test the Setup

1. **Landing Page:** Should load with professional design
2. **Sign In:** Click "Sign In" to test Auth0 authentication
3. **Profile:** After login, go to `/profile` to test profile creation
4. **Tools:** Go to `/tools` to test post creation interface
5. **Dashboard:** Main dashboard should show user stats

## 7. Production Deployment

### Vercel Deployment (Recommended)

1. Push your code to GitHub
2. Connect your repository to [Vercel](https://vercel.com)
3. Add production environment variables in Vercel dashboard
4. Update Auth0 settings with production URLs

### Production Environment Variables

Update these for production:
```env
APP_BASE_URL=https://your-domain.com
AUTH0_DOMAIN=your-auth0-domain.auth0.com
```

**v4 Changes:**
- Use `APP_BASE_URL` instead of `AUTH0_BASE_URL`
- Use `AUTH0_DOMAIN` instead of `AUTH0_ISSUER_BASE_URL` (without https://)

### Production Auth0 Settings

Update your Auth0 application:

**Allowed Callback URLs:**
```
https://your-domain.com/auth/callback
```

**Allowed Logout URLs:**
```
https://your-domain.com
```

**Allowed Web Origins:**
```
https://your-domain.com
```

## Troubleshooting

### Common Issues

**1. Auth0 Login Loop**
- Check that `AUTH0_SECRET` is properly set
- Verify Auth0 callback URLs match exactly
- Ensure Auth0 domain includes `https://`

**2. Database Connection Errors**
- Verify Supabase URL and keys are correct
- Check that database schema has been created
- Ensure Supabase project is active

**3. Build Errors**
- Run `rm -rf .next` to clear Next.js cache
- Check TypeScript errors with `npm run build`
- Verify all environment variables are set

**4. Missing Features**
- AI features require OpenAI API key (optional)
- Social media posting requires API integration (in development)
- Analytics require actual social media posts first

### Getting Help

1. Check the [troubleshooting section](troubleshooting.md)
2. Review the [company values](company-values.md) for feature expectations
3. Create an issue in the GitHub repository

## Development Commands

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Run linting
npm run lint

# Start production server
npm start
```

## File Structure Overview

```
├── src/app/              # Next.js pages and API routes
├── src/components/       # React components
├── src/lib/              # Utility functions
├── docs/                 # Documentation
├── public/               # Static assets
└── supabase-schema.sql   # Database schema
```

You're now ready to start developing! The platform emphasizes transparency and user choice - every feature is designed to empower users rather than create dependency.