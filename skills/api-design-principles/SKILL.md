# Skill: API Design Principles

## Use this skill when
- Designing new REST or GraphQL APIs
- Refactoring existing APIs
- Establishing API design standards
- Reviewing API specs before implementation
- Migrating between API paradigms

## Key Topics
- REST vs GraphQL style selection
- Resource modeling and naming
- HTTP methods and status codes
- Error format standardization
- Versioning strategies (URI, header, query)
- Pagination patterns
- Auth strategy (JWT, OAuth, API Keys)
- Rate limiting (token bucket, sliding window)
- OpenAPI/Swagger documentation
- OWASP API Top 10 security testing

## When to Use REST vs GraphQL
- REST: Simple CRUD, public APIs, caching important, team unfamiliar with GraphQL
- GraphQL: Complex relationships, multiple clients with different needs, real-time subscriptions

## Versioning Strategy
- URI versioning: /v1/resource (simple, visible)
- Header versioning: Accept: application/vnd.api.v1+json (clean URLs)
- Query versioning: ?version=1 (simple but less standard)

## Error Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [...]
  }
}
```

## Anti-Patterns
- ❌ No versioning
- ❌ Inconsistent error formats
- ❌ Over-fetching/under-fetching
- ❌ Verbs in URLs (/getUsers)
- ❌ Breaking changes without version bump
