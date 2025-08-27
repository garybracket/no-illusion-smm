# Deployment Guide - Social Media Manager

## Overview

This guide covers deploying the complete Social Media Manager application including the new Custom Prompt Templates system.

## Production Architecture

- **Frontend**: Next.js 15 on Vercel
- **Database**: Supabase PostgreSQL 
- **Authentication**: Auth0
- **External APIs**: Social platforms + AI providers

## Database Deployment

### Current Schema Status
✅ **Deployed Tables:**
- Core application tables (profiles, posts, analytics, etc.)
- Prompt templates system (4 new tables)
- System templates loaded (3 default templates)

### Schema Files
- **`supabase-schema.sql`** - Complete original schema
- **`supabase/migrations/20250820145007_prompt_templates_system.sql`** - Prompt templates addition
- **`prompt-templates-schema.sql`** - Standalone prompt system schema

### Manual Deployment Process

Since CLI is not configured for this project (to avoid mixing personal/production Supabase accounts):

1. **Open Supabase Dashboard**: https://supabase.com/dashboard/project/mjlblgzkmpwqgmblqsng/sql
2. **For New Deployments**: Run complete schema from `supabase-schema.sql`
3. **For Updates**: Run specific migration files
4. **Verify**: Check tables in Database → Tables view

## Environment Configuration

### Required Environment Variables

```bash
# Auth0 Configuration
AUTH0_SECRET=<32-byte-hex-key>
AUTH0_DOMAIN=<tenant>.auth0.com
AUTH0_CLIENT_ID=<auth0-app-client-id>
AUTH0_CLIENT_SECRET=<auth0-app-secret>
AUTH0_BASE_URL=https://your-domain.com (prod) / http://localhost:3000 (dev)
AUTH0_ISSUER_BASE_URL=https://<tenant>.auth0.com
APP_BASE_URL=https://your-domain.com (prod) / http://localhost:3000 (dev)

# Supabase Database
NEXT_PUBLIC_SUPABASE_URL=<supabase-project-url>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<supabase-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<supabase-service-role-key>

# AI Services (Global Fallback - Users can configure their own)
OPENAI_API_KEY=<openai-api-key>
ANTHROPIC_API_KEY=<anthropic-api-key>
GOOGLE_API_KEY=<google-gemini-api-key>

# Social Media Platform APIs
FACEBOOK_APP_ID=<facebook-app-id>
FACEBOOK_APP_SECRET=<facebook-app-secret>
LINKEDIN_CLIENT_ID=<linkedin-client-id>
LINKEDIN_CLIENT_SECRET=<linkedin-client-secret>
TIKTOK_CLIENT_KEY=<tiktok-client-key>
TIKTOK_CLIENT_SECRET=<tiktok-client-secret>

# Email Services
RESEND_API_KEY=<resend-api-key>
EMAIL_PROVIDER=resend
FROM_EMAIL=noreply@yourdomain.com
```

### Development vs Production

**Development (.env.local):**
- `AUTH0_BASE_URL=http://localhost:3000`
- Local Supabase or SQLite database
- Auth0 development tenant

**Production (Vercel Environment Variables):**
- `AUTH0_BASE_URL=https://your-production-domain.com`
- Production Supabase project
- Auth0 production tenant

## Application Deployment

### Vercel Deployment

1. **Repository Setup**
   ```bash
   git add .
   git commit -m "Deploy prompt templates system"
   git push origin main
   ```

2. **Vercel Configuration**
   - Connect GitHub repository
   - Set environment variables in Vercel dashboard
   - Configure custom domain (if applicable)

3. **Build Settings**
   - Framework: Next.js
   - Build Command: `npm run build`
   - Output Directory: `.next`

### Build Verification

Before deployment, ensure build succeeds:

```bash
npm run build
npm run lint
```

Expected output: ✅ Compiled successfully

## Post-Deployment Verification

### 1. Authentication Test
- Visit `/auth/login`
- Complete Auth0 login flow
- Verify redirect to dashboard

### 2. Database Connectivity
- Check profile creation/loading
- Verify AI preferences save
- Test prompt template system

### 3. Feature Testing
- **Prompt Templates**: Create, edit, preview templates
- **AI Generation**: Test with API keys configured
- **Social Publishing**: Verify platform connections
- **Analytics**: Check data collection

### 4. Error Monitoring
- Check Vercel function logs
- Monitor Auth0 logs
- Verify Supabase connection health

## Database Migration Workflow

### For Future Schema Changes

1. **Create Migration**
   ```bash
   supabase migration new feature_name
   ```

2. **Edit Migration File**
   - Add SQL changes to generated file
   - Test locally first

3. **Deploy to Production**
   - Copy migration SQL
   - Run in Supabase Dashboard SQL Editor
   - Verify changes in Database → Tables

### Schema Backup

Before major changes:
1. Export current schema via Supabase Dashboard
2. Download full database backup (if needed)
3. Test migration on development environment first

## Troubleshooting

### Common Issues

**Build Errors:**
- Check TypeScript compilation
- Verify all imports are correct
- Ensure environment variables are set

**Auth0 Issues:**
- Verify callback URLs match deployment domain
- Check Auth0 tenant configuration
- Confirm environment variables

**Database Issues:**
- Verify Supabase connection string
- Check service role key permissions
- Confirm tables exist via dashboard

**API Rate Limits:**
- Monitor AI provider usage
- Check social platform quotas
- Verify error handling and fallbacks

### Logs and Monitoring

**Vercel Function Logs:**
- Real-time logs in Vercel dashboard
- Error tracking and performance metrics

**Auth0 Logs:**
- Login/logout activity
- Authentication errors and warnings

**Supabase Logs:**
- Database query performance
- Connection issues and errors

## Security Checklist

### Pre-Deployment Security

- [ ] Environment variables secured (no commits to repo)
- [ ] Auth0 production tenant configured
- [ ] Supabase RLS policies enabled (if applicable)
- [ ] API keys rotated and secured
- [ ] CORS settings configured properly

### Post-Deployment Security

- [ ] Test authentication flows
- [ ] Verify data access restrictions
- [ ] Check for exposed sensitive data
- [ ] Monitor for unusual activity
- [ ] Validate API endpoint security

## Monitoring and Maintenance

### Regular Maintenance Tasks

1. **Weekly**
   - Monitor Vercel deployment health
   - Check Auth0 usage and errors
   - Review Supabase performance

2. **Monthly**
   - Update dependencies (`npm audit`)
   - Review AI provider usage and costs
   - Check social platform API changes

3. **Quarterly**
   - Rotate API keys and secrets
   - Review and update documentation
   - Performance optimization review

### Performance Monitoring

**Key Metrics:**
- Page load times
- API response times
- Database query performance
- Error rates and user feedback

**Tools:**
- Vercel Analytics
- Auth0 Dashboard
- Supabase Dashboard
- Social platform developer consoles

## Rollback Procedures

### Application Rollback
1. **Vercel**: Previous deployment restoration via dashboard
2. **Environment Variables**: Restore previous values if changed
3. **Domain**: DNS changes if domain was modified

### Database Rollback
1. **Schema Changes**: Manual reversal via SQL
2. **Data Changes**: Restore from backup (if available)
3. **Migration Issues**: Contact Supabase support if needed

**Note**: Database rollbacks are more complex and should be planned carefully. Always test schema changes in development first.

## Support and Documentation

### Internal Documentation
- `CLAUDE.md` - Complete system documentation
- `docs/ARCHITECTURE.md` - System architecture overview
- `docs/PROMPT_TEMPLATES_API.md` - API documentation

### External Resources
- [Next.js 15 Documentation](https://nextjs.org/docs)
- [Auth0 Next.js SDK](https://auth0.com/docs/quickstart/webapp/nextjs)
- [Supabase Documentation](https://supabase.com/docs)
- [Vercel Deployment Guide](https://vercel.com/docs)