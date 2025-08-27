# Email & Notification System Setup

## Overview

The Social Media Manager includes a comprehensive email and notification system based on your MXroute implementation from no-illusion-nextjs. It supports both SMTP (MXroute) and Resend email providers with a built-in notification engine.

## Features

### Email Service (`src/lib/email-service.ts`)
- **Dual Provider Support**: SMTP (MXroute) and Resend
- **Environment-Based Configuration**: Switch providers without code changes
- **Social Media Specific Templates**: Welcome, post published, post failed notifications
- **Connection Verification**: Built-in SMTP testing
- **Full TypeScript Support**

### Notification Service (`src/lib/notification-service.ts`)
- **Multi-Channel Notifications**: Email + in-app notifications
- **Persistent Storage**: Notifications stored in database
- **Read/Unread Tracking**: Mark notifications as read
- **Convenience Methods**: Pre-built notification types
- **Type Safety**: Full TypeScript interfaces

## Environment Variables

Add these to your `.env.local`:

```bash
# Email Provider Selection
EMAIL_PROVIDER=smtp  # or 'resend'

# Email Addresses  
FROM_EMAIL=noreply@yourdomain.com
CONTACT_EMAIL=admin@yourdomain.com

# MXroute SMTP Configuration (when EMAIL_PROVIDER=smtp)
SMTP_HOST=[server-name].mxrouting.net  # Replace with your MXroute server
SMTP_PORT=465                          # Secure SSL/TLS port (recommended)
SMTP_SECURE=true                       # Use SSL/TLS encryption
SMTP_USER=your-email@yourdomain.com    # Your full email address
SMTP_PASS=your-email-password          # Your email password

# Resend Configuration (when EMAIL_PROVIDER=resend)
RESEND_API_KEY=your-resend-api-key
```

## Database Schema

The notification system requires a `notifications` table (already added to `supabase-schema.sql`):

```sql
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL, -- Auth0 user ID
    type TEXT NOT NULL CHECK (type IN ('welcome', 'post_published', 'post_failed', 'platform_connected', 'platform_disconnected')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    read BOOLEAN DEFAULT false,
    email_sent BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
```

## API Endpoints

The system includes RESTful API endpoints:

- `GET /api/notifications` - Get user notifications
- `POST /api/notifications` - Send custom notification
- `PATCH /api/notifications/[id]` - Mark notification as read
- `POST /api/notifications/mark-all-read` - Mark all notifications as read
- `GET /api/notifications/unread-count` - Get unread notification count

## Usage Examples

### Basic Email Service

```typescript
import { EmailService } from '@/lib/email-service'

const emailService = new EmailService()

// Send custom email
await emailService.sendEmail({
  to: 'user@example.com',
  from: process.env.FROM_EMAIL!,
  subject: 'Test Email',
  html: '<h1>Hello World</h1>',
  text: 'Hello World'
})

// Send welcome email
await emailService.sendWelcomeEmail('user@example.com', 'John Doe')
```

### Notification Service

```typescript
import { NotificationService } from '@/lib/notification-service'

const notificationService = new NotificationService()

// Send welcome notification (email + in-app)
await notificationService.notifyWelcome('user-id', true)

// Send post published notification
await notificationService.notifyPostPublished(
  'user-id', 
  ['facebook', 'instagram'], 
  'Post content here',
  true // send email
)

// Get user notifications
const notifications = await notificationService.getUserNotifications('user-id', 20)

// Mark notification as read
await notificationService.markNotificationAsRead('notification-id')
```

## Integration Points

### 1. User Registration
Add to your Auth0 post-login action or profile creation:

```typescript
import { NotificationService } from '@/lib/notification-service'

const notificationService = new NotificationService()
await notificationService.notifyWelcome(user.sub, true)
```

### 2. Post Publishing
Add to your post publishing logic:

```typescript
// On successful post
await notificationService.notifyPostPublished(
  userId, 
  platforms, 
  postContent, 
  true
)

// On failed post
await notificationService.notifyPostFailed(
  userId, 
  platforms, 
  error.message, 
  true
)
```

### 3. Platform Connections
Add to your platform connection handlers:

```typescript
// On platform connect
await notificationService.notifyPlatformConnected(userId, 'facebook', false)

// On platform disconnect  
await notificationService.notifyPlatformDisconnected(userId, 'facebook', false)
```

## Auth0 Custom Email Provider

### Current Limitation
Auth0 primarily supports these email providers out of the box:
- Amazon SES
- Mailgun
- Mandrill  
- SendGrid
- SparkPost

**MXroute is not directly supported** as an Auth0 email provider.

### Workarounds for Auth0 Emails

#### Option 1: Use Resend with Auth0
1. Set up Resend account (they support custom domains)
2. Configure Auth0 to use Resend
3. Use MXroute for application emails, Resend for Auth0 emails

#### Option 2: SMTP Forwarding
1. Set up email forwarding from MXroute to a supported provider
2. Configure Auth0 with the supported provider
3. Use MXroute directly for application emails

#### Option 3: Custom Auth0 Extension (Advanced)
Create a custom Auth0 extension that uses your EmailService:

```javascript
// Auth0 Rule/Action (simplified example)
function(user, context, callback) {
  if (context.stats.loginsCount === 1) {
    // First login - send welcome email via your API
    request.post({
      url: 'https://your-app.com/api/notifications',
      headers: { 'Authorization': 'Bearer ' + context.accessToken },
      json: {
        type: 'welcome',
        title: 'Welcome!',
        message: 'Welcome to SocialHub',
        email: true
      }
    }, function(err, response, body) {
      callback(null, user, context);
    });
  } else {
    callback(null, user, context);
  }
}
```

## Security Notes

- Never commit `.env.local` to version control
- Use strong, unique passwords for email accounts
- Always use encrypted connections (SSL/TLS)
- Regularly rotate email passwords
- Monitor email logs for suspicious activity
- Rate limit notification endpoints

## Testing

Test your email configuration:

```bash
# Test SMTP connection
curl -X POST http://localhost:3000/api/notifications \
  -H "Content-Type: application/json" \
  -d '{"type":"welcome","title":"Test","message":"Test message","email":true}'
```

## Troubleshooting

### Common Issues

1. **SMTP Authentication Failed**: Verify username is full email address
2. **Port Blocked**: Try alternative ports (587, 2525)  
3. **SSL Errors**: Ensure SMTP_SECURE matches port (465=true, 587=false)
4. **Auth0 Emails Not Working**: Use one of the workaround options above

### MXroute Specific Settings

```bash
# Example MXroute settings
SMTP_HOST=arrow.mxrouting.net  # Replace with your actual server
SMTP_PORT=465
SMTP_SECURE=true
SMTP_USER=contact@yourdomain.com
SMTP_PASS=your-secure-password
```

The system is designed to be production-ready and handles errors gracefully while providing detailed logging for troubleshooting.