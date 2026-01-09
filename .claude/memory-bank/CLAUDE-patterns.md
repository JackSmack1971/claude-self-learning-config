# Coding Patterns Library
**Last Updated**: 2026-01-09
**Auto-Sync**: Enabled

---

## 📐 Pattern Template

```markdown
### [Pattern Name]
**Category**: [Architecture/Testing/Performance/Security/etc.]
**Confidence**: ⭐⭐⭐⭐⭐ (5/5)
**Last Used**: YYYY-MM-DD
**Success Rate**: XX%

**Context**: When to use this pattern
**Implementation**: How to implement
**Example**: Code snippet
**Rationale**: Why this works
**Pitfalls**: Common mistakes to avoid
**Related Patterns**: Links to similar patterns
```

---

## 🎯 Active Patterns

### Repository Structure Pattern
**Category**: Architecture
**Confidence**: ⭐⭐⭐⭐⭐
**Last Used**: 2026-01-09
**Success Rate**: 100%

**Context**: Setting up a new project repository
**Implementation**:
```
project-root/
├── src/
│   ├── core/          # Business logic
│   ├── features/      # Feature modules
│   ├── shared/        # Shared utilities
│   └── infrastructure/ # External integrations
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docs/
│   ├── architecture/
│   ├── api/
│   └── guides/
└── .claude/           # AI configuration
```

**Rationale**: Clear separation of concerns, scalable structure
**Pitfalls**: Don't mix business logic with infrastructure
**Related Patterns**: Feature Module Pattern, Domain-Driven Design

---

### Error Handling Pattern
**Category**: Reliability
**Confidence**: ⭐⭐⭐⭐⭐
**Last Used**: 2026-01-09
**Success Rate**: 95%

**Context**: Handling errors consistently across the application
**Implementation**:
```typescript
// Custom error classes
class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number = 500,
    public isOperational: boolean = true
  ) {
    super(message);
    Error.captureStackTrace(this, this.constructor);
  }
}

// Global error handler
const errorHandler = (err: Error, req, res, next) => {
  if (err instanceof AppError && err.isOperational) {
    return res.status(err.statusCode).json({
      status: 'error',
      code: err.code,
      message: err.message
    });
  }
  
  // Log unexpected errors
  logger.error('Unexpected error:', err);
  return res.status(500).json({
    status: 'error',
    message: 'Internal server error'
  });
};
```

**Rationale**: Distinguishes between operational and programming errors
**Pitfalls**: Don't expose internal error details to clients
**Related Patterns**: Circuit Breaker, Retry Pattern

---

## 📦 Pattern Categories

### Architecture Patterns
- [ ] Hexagonal Architecture
- [ ] Event-Driven Architecture
- [ ] Microservices Communication
- [ ] API Gateway Pattern

### Testing Patterns
- [ ] Test Data Builders
- [ ] Mock Service Worker Setup
- [ ] Integration Test Patterns
- [ ] E2E Test Organization

### Performance Patterns
- [ ] Caching Strategy
- [ ] Database Query Optimization
- [ ] Lazy Loading
- [ ] Resource Pooling

### Security Patterns
- [ ] Authentication Flow
- [ ] Authorization Middleware
- [ ] Input Validation
- [ ] Secret Management

---

## 🔄 Pattern Evolution Tracking

| Pattern Name | Version | Change Date | Change Type | Success Impact |
|-------------|---------|-------------|-------------|----------------|
| Error Handling | 2.0 | 2026-01-09 | Enhancement | +15% reliability |
| Repository Structure | 1.5 | 2026-01-09 | Refinement | +20% maintainability |

---

## 💡 Pattern Discovery Queue

Patterns identified but not yet formalized:
1. Database migration rollback strategy
2. Feature flag implementation
3. Logging correlation ID pattern
4. Background job processing

---

## 📊 Pattern Usage Statistics

**Most Used Patterns (Last 30 Days)**:
1. Error Handling Pattern - 47 uses
2. Repository Structure - 12 uses
3. API Response Pattern - 38 uses

**Highest Success Rate**:
1. Repository Structure - 100%
2. Error Handling - 95%
3. Testing Setup - 92%

---

**Auto-Update Instructions**:
- This file syncs automatically after successful task completion
- Manual updates via `#` shortcut are immediately reflected
- Unused patterns (0 uses in 90 days) are archived monthly
