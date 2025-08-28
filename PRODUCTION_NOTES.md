# Production Issues & Notes

## Current Known Issues

### Account Tier Display Issue
**Date**: August 28, 2025  
**Issue**: Gary's account shows "free tier" in profile but has all Pro/Ultimate permissions and unlimited AI usage  
**Impact**: Low - functionality works correctly, just display issue  
**Priority**: Low  
**Status**: Deferred - functionality works, cosmetic only  

**Technical Details:**
- User subscription_tier field shows "free" 
- But AI features and usage limits are not enforced
- All premium features accessible
- Likely caused by manual database setup vs proper subscription flow

**TODO**: Investigate subscription tier enforcement and display logic when implementing Stripe integration

## Facebook Integration Status

### Facebook App Configuration
**App ID**: 981014477450029  
**Status**: Environment variables set in development and production  
**Issue**: Facebook Developer Console doesn't show pages_manage_posts permission in available options  
**Next Steps**: User needs to find correct permission settings in updated Facebook interface