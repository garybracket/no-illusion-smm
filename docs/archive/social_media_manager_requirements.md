# 📄 Requirements Document (Rails Implementation)
## Project Title: **No iLLusion SMM - Rails Social Media Manager**

### 1. Overview
A Ruby on Rails freemium SaaS platform for social media management. Complete rebuild from Next.js/Supabase to Rails for better maintainability, deployment simplicity, and monolithic architecture. **Current focus: LinkedIn integration with full OAuth, content publishing, and profile synchronization.**

---

### 2. Goals - **✅ ACHIEVED**
- ✅ Provide an easy-to-use Rails dashboard for managing social media
- ✅ Complete LinkedIn integration with OAuth, posting, and profile sync
- ✅ AI-powered content generation based on user profiles and skills
- ✅ Professional resume builder with LinkedIn data import
- ✅ Build with Rails conventions and PostgreSQL for production reliability

---

### 3. Tech Stack - **RAILS IMPLEMENTATION**

| Layer             | Tool/Framework        | Status & Notes                                                      |
|------------------|------------------------|------------------------------------------------------------| 
| **Backend**      | **Ruby on Rails 7.1**  | Complete MVC architecture, PostgreSQL - **✅ COMPLETE**  |
| **Frontend**     | **Rails Views + Stimulus** | Tailwind CSS, mobile-first responsive - **✅ COMPLETE**  |
| **Authentication** | **Devise + Auth0**    | Secure user management and OAuth - **✅ COMPLETE**    |
| **Database**     | **PostgreSQL**        | Production-ready with Rails migrations - **✅ COMPLETE**   |
| **AI Integration** | **Claude API (Anthropic)** | Profile-based content generation - **✅ COMPLETE**        |
| **LinkedIn API** | **LinkedIn v2 OAuth** | Complete integration with posting + profiles - **✅ COMPLETE**             |
| **Deployment**   | **Heroku Ready**      | Single app deployment with PostgreSQL - **✅ READY**               |

---

### 4. Functional Requirements

#### 4.1 User Authentication & Management - **✅ RAILS COMPLETE**
- ✅ **Devise + Auth0 Integration**: Secure user authentication with OAuth
- ✅ **User Model**: Complete profile system with skills, bio, mission statement  
- ✅ **Session Management**: Rails session handling with Auth0 user identification
- ✅ **Profile Validation**: Active Record validations for user data integrity
- ✅ **Content Mode Support**: Business, influencer, personal content preferences

#### 4.2 LinkedIn Integration - **✅ COMPLETE**
- ✅ **OAuth 2.0 Flow**: Full LinkedIn authentication with CSRF protection
- ✅ **Profile Import**: LinkedIn data → app profile synchronization
  - Name, headline, summary, work history, education
  - Skills extraction with business/technical categorization
  - Profile picture import with URL handling
- ✅ **Profile Export**: App profile → formatted LinkedIn content
  - Professional headline generation
  - Formatted About section with skills
  - Experience templates for LinkedIn
  - Copy-to-clipboard functionality
- ✅ **Content Publishing**: LinkedIn posts with text + images
- ✅ **Connection Management**: Token storage, expiration, status tracking

#### 4.3 Content Management - **✅ COMPLETE**
- ✅ **Posts System**: Create, edit, publish posts with Rails CRUD
- ✅ **AI Content Generation**: Claude API integration with profile context
- ✅ **Content Modes**: Business/influencer/personal content strategies
- ✅ **Prompt Templates**: User-specific AI prompt management
- ✅ **Status Tracking**: Draft, scheduled, published, failed states

#### 4.4 Resume Builder - **✅ COMPLETE**  
- ✅ **LinkedIn Integration**: Auto-import work history and education
- ✅ **Professional Formatting**: Clean, professional resume layout
- ✅ **Skills Integration**: Technical/business skills categorization
- ✅ **Mission Statement**: Professional branding incorporation
- ✅ **Preview & Download**: Resume generation and export

#### 4.3 Tools Page
A central page containing:

##### 4.3.1 Platform Connections
- ✅ Connect API keys or OAuth tokens for:
  - Facebook - **UI COMPLETE**
  - Instagram - **UI COMPLETE**
  - LinkedIn - **UI COMPLETE**
- ✅ View connection status and disconnect/reconnect - **UI COMPLETE**
- ⏳ Actual OAuth flows - **PENDING API INTEGRATION**

##### 4.3.2 Post Creator UI
- ✅ Text area for writing a post - **COMPLETE**
- ✅ Image upload (Drag & Drop, preview) - **COMPLETE**
- ✅ Checkboxes for selecting platforms (e.g., [x] Facebook, [ ] Instagram) - **COMPLETE**
- ✅ "Post" button to simultaneously publish to selected platforms - **UI COMPLETE**
- ✅ Preview post content before publishing - **COMPLETE**
- ✅ History/log of recent posts with status - **DATABASE READY**
- ⏳ Actual posting to social media platforms - **PENDING API INTEGRATION**

##### 4.3.3 AI Assistance (Optional)
- ✅ Button labeled "AI Assist (Optional)" - **COMPLETE**
- ✅ Clear messaging about optional nature - **COMPLETE**
- ✅ On click:
  - Fetch user's skills and mission statement - **COMPLETE**
  - Send prompt to AI model to generate content - **COMPLETE**
  - Pre-fill post editor with the result - **COMPLETE**
- ✅ Fallback content generation when AI unavailable - **COMPLETE**
- ✅ Mission statement integration for brand-aligned content - **COMPLETE**

---

### 5. Non-Functional Requirements
- ⚡ Fast and responsive UI (Tailwind CSS recommended)
- 🔐 Secure API key handling (encrypted storage)
- ☁️ Deployed and auto-scaling (e.g., Vercel edge functions)
- 📱 Mobile-friendly and accessible
- 📊 Scalable database schema (multi-user and multi-post support)
- 🧪 Basic test coverage for key components

---

### 6. Database Schema (Supabase)

#### Tables:
- `users`:
  - `id`, `email`, `name`, `avatar_url`, etc.

- `profiles`:
  - `user_id`, `bio`, `skills (JSONB array)`, etc.

- `platform_connections`:
  - `user_id`, `platform_name`, `access_token`, `settings`

- `posts`:
  - `id`, `user_id`, `content`, `image_url`, `platforms (array)`, `status`, `created_at`

- `post_logs`:
  - `post_id`, `platform`, `status`, `response_message`

---

### 7. External APIs & Integrations

| Platform    | Method              | Notes                                                    |
|-------------|---------------------|----------------------------------------------------------|
| Facebook    | Graph API           | Page token required                                      |
| Instagram   | Graph API           | Via linked Facebook page                                 |
| LinkedIn    | REST API            | Requires app registration + token                        |
| OpenAI GPT  | API (Custom GPT)    | Custom instructions + skill-based prompt for content     |

---

### 8. User Roles
- **Standard User**: Default access, profile & post management
- **Admin (optional future)**: View all user data, moderate content

---

### 9. AI Content Logic

#### Example Prompt Logic
```
"Create a social media post targeting small business customers, using the user's skills: [Marketing, SEO]. The tone should be professional but engaging."
```

- Skill list used as context
- Custom GPT returns a suggested post
- User can edit before publishing

---

### 10. MVP Roadmap

| Milestone        | Features                                                                 | Status |
|------------------|--------------------------------------------------------------------------|--------| 
| **M1: Auth + Infrastructure** | Auth0 setup, Supabase database, basic routing, professional UI   | ✅ **COMPLETE** |
| **M2: Profile Management**    | User profile editor, skills selection, mission statements        | ✅ **COMPLETE** |
| **M2b: AI-Inclusive Design** | Optional AI assistance, company values framework                 | ✅ **COMPLETE** |
| **M3: Social Media APIs**    | Connect platforms, OAuth flows, actual posting capability        | ⏳ **PENDING** |
| **M4: Smart Analytics**      | Real post performance tracking (requires M3 first)               | ⏳ **PENDING** |
| **M5: AI Enhancement**       | Advanced AI features, OpenAI integration, content optimization   | ⏳ **PENDING** |
| **M6: Advanced Features**    | Post scheduling, image editing, team collaboration               | ⏳ **PENDING** |
| **M7: Polish & Deploy**     | Performance optimization, monitoring, production deployment       | ⏳ **PENDING** |

---

### 11. Optional Features (Post-MVP)
- Post scheduling
- Post analytics (impressions, clicks)
- Team roles (multi-user per business)
- Templates and post drafts
- AI rewrite/optimize suggestions

---

### 12. Hosting and Deployment

- **Frontend**: Vercel (Next.js)
- **Backend & DB**: Supabase or optional Rails backend
- **Custom GPT**: ChatGPT Custom GPT + OpenAI API keys
- **Environment Management**: `.env.local` for local dev, Vercel Env Vars for prod