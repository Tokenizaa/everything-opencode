# Skill: Backend Development Guidelines

## Use this skill when
- Building backend services, APIs, microservices
- Implementing routes, controllers, services, repositories
- Working with Node.js + Express + TypeScript
- Designing database access layers
- Implementing authentication and authorization
- Setting up middleware pipelines

## Key Topics
- Layered architecture (Routes → Controllers → Services → Repositories)
- BFRI (Backend Feasibility & Risk Index)
- BaseController pattern
- Dependency injection
- Prisma repository encapsulation
- Zod input validation
- Unified config as sole config source
- Sentry error tracking
- asyncErrorWrapper
- Testing discipline (unit/integration/repository)
- Naming conventions

## Architecture Layers

### Routes
- Thin controllers, delegate to services
- Handle HTTP concerns only (status codes, headers)
- Input validation via Zod schemas

### Controllers
- Extend BaseController
- Handle request/response mapping
- No business logic

### Services
- Pure business logic
- No HTTP dependencies
- Use repositories for data access
- Transaction management

### Repositories
- Encapsulate Prisma/database access
- Single responsibility per entity
- Return domain entities, not Prisma models

## Validation
- Zod schemas for all inputs
- Validate at route level (edge)
- Shared schemas between frontend/backend

## Error Handling
- asyncErrorWrapper for all async handlers
- Standardized error codes
- Sentry integration for tracking

## Testing
- Unit tests for services (mock repositories)
- Integration tests for routes (testcontainers)
- Repository tests with test database

## Configuration
- Single `unifiedConfig` object
- Environment-based, validated at startup
- No process.env scattered in code

## Anti-Patterns
- ❌ Business logic in controllers
- ❌ Direct Prisma access in services
- ❌ Scattered process.env usage
- ❌ Missing error handling
- ❌ Direct database access in routes
