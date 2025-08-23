# Prompt Templates API Documentation

## Overview

The Prompt Templates system provides complete CRUD operations for managing custom AI prompt templates. Users can create, edit, share, and use personalized prompts for content generation.

## Authentication

All endpoints require Auth0 authentication. The `user_id` is extracted from the Auth0 session (`sub` claim).

## Core Endpoints

### GET /api/prompt-templates

Retrieve prompt templates with filtering options.

**Query Parameters:**
- `mode` (optional): Filter by content mode (`business`, `influencer`, `personal`, `custom`)
- `public` (optional): Include public templates (`true`/`false`)
- `system` (optional): Include system templates (`true`/`false`)

**Response:**
```json
{
  "templates": [
    {
      "id": "uuid",
      "user_id": "auth0|123456",
      "name": "My Business Template",
      "description": "Custom template for professional content",
      "content_mode": "business",
      "prompt_text": "Create content for {platforms} about {skills}...",
      "is_default": false,
      "is_public": false,
      "is_system": false,
      "variables": ["platforms", "skills", "mission_statement"],
      "platforms": ["linkedin", "twitter"],
      "tags": ["professional", "business"],
      "usage_count": 5,
      "last_used_at": "2024-01-15T10:30:00Z",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### POST /api/prompt-templates

Create a new prompt template.

**Request Body:**
```json
{
  "name": "My Custom Template",
  "description": "Template description",
  "content_mode": "business",
  "prompt_text": "Create professional content about {skills} for {platforms}. Mission: {mission_statement}",
  "is_default": false,
  "is_public": false,
  "variables": ["skills", "platforms", "mission_statement"],
  "platforms": ["linkedin", "twitter"],
  "tags": ["professional", "custom"]
}
```

**Response:**
```json
{
  "template": {
    "id": "new-uuid",
    "user_id": "auth0|123456",
    "name": "My Custom Template",
    // ... full template object
  }
}
```

### GET /api/prompt-templates/[id]

Retrieve a specific template by ID. User must own the template, or it must be public/system.

**Response:**
```json
{
  "template": {
    "id": "uuid",
    // ... full template object
  }
}
```

### PUT /api/prompt-templates/[id]

Update an existing template. User must own the template.

**Request Body:** Same as POST (all fields optional)

**Response:**
```json
{
  "template": {
    "id": "uuid",
    // ... updated template object
  }
}
```

### DELETE /api/prompt-templates/[id]

Delete a template. User must own the template (cannot delete system templates).

**Response:**
```json
{
  "message": "Template deleted successfully"
}
```

### POST /api/prompt-templates/[id]/copy

Copy a public or system template to user's library.

**Request Body:**
```json
{
  "name": "My Copy of Template",
  "description": "Customized version"
}
```

**Response:**
```json
{
  "template": {
    "id": "new-uuid",
    "user_id": "auth0|123456",
    "name": "My Copy of Template",
    // ... copied template with user modifications
  }
}
```

### POST /api/prompt-templates/preview

Preview how a template resolves with actual user data.

**Request Body:**
```json
{
  "prompt_text": "Create content for {platforms} about {skills}. Mission: {mission_statement}",
  "variables": {
    "platforms": "LinkedIn, Twitter",
    "skills": "web development, AI",
    "mission_statement": "Building accessible technology"
  }
}
```

**Response:**
```json
{
  "resolved_prompt": "Create content for LinkedIn, Twitter about web development, AI. Mission: Building accessible technology",
  "variables_used": {
    "platforms": "LinkedIn, Twitter",
    "skills": "web development, AI", 
    "mission_statement": "Building accessible technology"
  },
  "unresolved_variables": [],
  "character_count": 125,
  "word_count": 18
}
```

## Variable Substitution

Templates support dynamic variable substitution using `{variable_name}` syntax.

### Standard Variables

These variables are automatically available from user profiles:

- `{skills}` - User's skills array (joined as comma-separated string)
- `{mission_statement}` - User's business mission statement
- `{platforms}` - Target platforms for the content
- `{name}` - User's display name
- `{bio}` - User's bio/description

### Custom Variables

Templates can define custom variables that will be prompted for during content generation.

## Error Handling

All endpoints return appropriate HTTP status codes:

- `200` - Success
- `201` - Created (for POST requests)
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (no valid session)
- `403` - Forbidden (user doesn't own resource)
- `404` - Not Found (template doesn't exist)
- `500` - Internal Server Error

**Error Response Format:**
```json
{
  "error": "Error message",
  "details": "Optional detailed error information"
}
```

## Integration with AI Generation

The prompt templates integrate seamlessly with the AI content generation system:

1. **Template Selection**: Users can specify a `prompt_template_id` in generation requests
2. **Fallback Hierarchy**: System follows this order:
   - Custom prompt (if provided)
   - Selected template (if `prompt_template_id` provided)
   - User's default template for the content mode
   - System default template for the content mode
   - Built-in fallback prompt

3. **Usage Tracking**: All template usage is logged in `prompt_generation_logs` table

## System Templates

The system includes 3 built-in templates:

1. **Professional Business Content** (`business` mode)
2. **Influencer Content Creator** (`influencer` mode) 
3. **Personal Authentic Voice** (`personal` mode)

These templates:
- Cannot be deleted or modified
- Are available to all users
- Serve as starting points for custom templates
- Can be copied and customized

## Security Considerations

- All templates are filtered by user ownership and visibility
- Public templates can only be read, not modified by non-owners
- System templates cannot be modified by any user
- Template sharing is tracked for analytics and community features
- All user data substitution happens server-side for security