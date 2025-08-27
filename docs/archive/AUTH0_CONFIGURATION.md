# Auth0 Configuration Guide

## Required Auth0 Dashboard Settings

### Application Settings

1. **Allowed Callback URLs**:
   - Development: `http://localhost:3000/auth/callback`
   - Production: `https://smm.no-illusion.com/auth/callback`

2. **Allowed Logout URLs** (CRITICAL - Must be exact, no trailing spaces):
   - Development: `http://localhost:3000`
   - Production: `https://smm.no-illusion.com`

3. **Allowed Web Origins**:
   - Development: `http://localhost:3000`
   - Production: `https://smm.no-illusion.com`

### Important Notes

- **No Trailing Spaces**: Ensure there are NO trailing spaces or special characters in any URL
- **Exact Match**: Auth0 requires exact URL matching - the returnTo URL must exactly match one of the allowed logout URLs
- **Protocol Required**: Always include the protocol (http:// or https://)
- **No Trailing Slashes**: Do not add trailing slashes to the logout URLs

### Environment Variables

Ensure these are set correctly in your production environment:

```env
AUTH0_DOMAIN=your-tenant.auth0.com  # No https:// prefix
AUTH0_CLIENT_ID=your-client-id
AUTH0_CLIENT_SECRET=your-client-secret
AUTH0_SECRET=your-32-byte-secret
APP_BASE_URL=https://smm.no-illusion.com  # No trailing slash or space
```

### Troubleshooting Logout Issues

If you see the error "The returnTo URL is malformed":

1. Check Auth0 Dashboard > Applications > Your App > Settings
2. Verify "Allowed Logout URLs" contains exactly: `https://smm.no-illusion.com`
3. Ensure no trailing spaces, slashes, or special characters
4. Save changes in Auth0 dashboard
5. Clear browser cookies and try again

### Testing

After configuration:
1. Test logout in development: `http://localhost:3000/auth/logout`
2. Test logout in production: `https://smm.no-illusion.com/auth/logout`
3. Verify you're redirected to the home page after logout