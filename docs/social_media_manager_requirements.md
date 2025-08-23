# 📄 Requirements Document
## Project Title: **Small Business Social Media Manager**

### 1. Overview
This application helps small business owners manage social media presence across multiple platforms (Facebook, Instagram, LinkedIn, TikTok) from a single interface. It allows users to connect their accounts, create and publish posts, and generate AI-powered marketing content based on their profile skills.

---

### 2. Goals
- Provide an easy-to-use dashboard for managing social media.
- Support posting to multiple platforms simultaneously.
- Use AI to generate marketing content based on user skill profiles.
- Allow users to manage platform settings (e.g., API keys).
- Build with scalable, modern technologies (Next.js + Supabase).

---

### 3. Tech Stack

| Layer             | Tool/Framework        | Notes                                                      |
|------------------|------------------------|------------------------------------------------------------| 
| Frontend         | **Next.js 15 (React)**  | App Router, TypeScript, Tailwind CSS - Hosted on Vercel  |
| Authentication   | **Auth0 v4.9.0**        | OAuth, session management, user identity - **✅ COMPLETE (v4 Migration)**    |
| Database         | **Supabase**            | PostgreSQL database only (no auth features) - **✅ COMPLETE**   |
| AI Integration   | **Multi-Provider AI**   | OpenAI, Anthropic, Google - Smart fallback cycling - **✅ COMPLETE**        |
| Social APIs      | **All 4 Platforms**     | Facebook, Instagram, LinkedIn, TikTok - **✅ COMPLETE**             |
| Hosting          | **Vercel**              | Frontend deployment and hosting - **✅ COMPLETE**               |

---

### 4. Functional Requirements

#### 4.1 User Authentication
- ✅ User signup & login (Auth0) - **COMPLETE**
- ✅ OAuth with Google via Auth0 - **COMPLETE**
- ✅ Store basic user metadata (name, email, avatar, etc.) in Supabase - **COMPLETE**
- ✅ Auth0 user ID (sub claim) used as foreign key in database - **COMPLETE**
- ✅ Session management via Auth0 SDK middleware - **COMPLETE**
- ✅ Dynamic UI based on authentication state - **COMPLETE**

#### 4.2 Profile Page
- ✅ Editable user profile - **COMPLETE**
- ✅ Skill list (predefined and selectable) - **COMPLETE**
  - Example skills: Marketing, Graphic Design, SEO, Copywriting, Content Creation, etc.
- ✅ Option to update profile information and skillset - **COMPLETE**
- ✅ Mission statement integration - **COMPLETE**
  - Template: "We help [target audience] [achieve what] through [your approach/values]"
  - Industry-specific examples and guidance
  - Integration with AI content generation

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