# Code Snippets Library
**Last Updated**: 2026-01-09
**Purpose**: Reusable code patterns with copy-paste implementations

---

## 📋 Snippet Template

```markdown
### [Snippet Name]
**Language**: [TypeScript/Python/Bash/etc.]
**Category**: [Error Handling/API/Database/Testing/etc.]
**Dependencies**: [List required packages]
**Related Pattern**: Link to CLAUDE-patterns.md entry

**Description**: Brief explanation of what this does

**Usage**:
When to use this snippet

**Code**:
```language
// Copy-paste ready code
```

**Example**:
```language
// How to use it in context
```

**Customization Points**:
- Point 1: What to change
- Point 2: What to adapt

**Gotchas**:
- Pitfall 1
- Pitfall 2
```

---

## 🎯 Active Snippets

### Custom Error Class (TypeScript)
**Language**: TypeScript
**Category**: Error Handling
**Dependencies**: None
**Related Pattern**: Error Handling Pattern (CLAUDE-patterns.md)

**Description**: Base class for application-specific errors with operational flag

**Usage**: Create domain-specific error types for different failure modes

**Code**:
```typescript
export class AppError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly statusCode: number = 500,
    public readonly isOperational: boolean = true,
    public readonly metadata?: Record<string, any>
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }

  toJSON() {
    return {
      name: this.name,
      code: this.code,
      message: this.message,
      statusCode: this.statusCode,
      ...(this.metadata && { metadata: this.metadata })
    };
  }
}

// Domain-specific errors
export class ValidationError extends AppError {
  constructor(message: string, metadata?: Record<string, any>) {
    super('VALIDATION_ERROR', message, 400, true, metadata);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, identifier: string) {
    super(
      'NOT_FOUND',
      `${resource} with identifier '${identifier}' not found`,
      404,
      true,
      { resource, identifier }
    );
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized access') {
    super('UNAUTHORIZED', message, 401, true);
  }
}
```

**Example**:
```typescript
// In your service layer
async function getUserById(id: string): Promise<User> {
  const user = await db.users.findById(id);
  
  if (!user) {
    throw new NotFoundError('User', id);
  }
  
  return user;
}

// In your validation layer
function validateEmail(email: string): void {
  if (!isValidEmail(email)) {
    throw new ValidationError('Invalid email format', { 
      field: 'email', 
      value: email 
    });
  }
}
```

**Customization Points**:
- `code`: Change to match your error taxonomy
- `statusCode`: Adjust HTTP status as needed
- `metadata`: Add context-specific information

**Gotchas**:
- Always set `isOperational: false` for programmer errors (bugs)
- Don't expose sensitive metadata to clients
- Use specific error classes rather than generic AppError

---

### Global Error Handler (Express)
**Language**: TypeScript
**Category**: Error Handling
**Dependencies**: express
**Related Pattern**: Error Handling Pattern

**Description**: Centralized Express middleware for error handling

**Usage**: Register as last middleware in Express app

**Code**:
```typescript
import { Request, Response, NextFunction } from 'express';
import { AppError } from './errors';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  // Operational errors (expected)
  if (err instanceof AppError && err.isOperational) {
    res.status(err.statusCode).json({
      status: 'error',
      code: err.code,
      message: err.message,
      ...(process.env.NODE_ENV === 'development' && { 
        stack: err.stack 
      })
    });
    return;
  }

  // Programming errors (bugs)
  console.error('❌ Unexpected Error:', err);
  
  // Don't expose internal errors to clients
  res.status(500).json({
    status: 'error',
    code: 'INTERNAL_ERROR',
    message: process.env.NODE_ENV === 'production' 
      ? 'An unexpected error occurred'
      : err.message
  });
};

// Async handler wrapper to catch promise rejections
export const asyncHandler = (
  fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};
```

**Example**:
```typescript
import express from 'express';
import { errorHandler, asyncHandler } from './middleware/errorHandler';

const app = express();

// Routes with async handler
app.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await getUserById(req.params.id); // May throw NotFoundError
  res.json(user);
}));

// Error handler must be last
app.use(errorHandler);
```

**Customization Points**:
- Logging strategy (console.error → proper logger)
- Error response format
- Environment-specific behavior

**Gotchas**:
- Must be registered AFTER all routes
- Use `asyncHandler` for async route handlers
- Don't call `next()` in sync handlers for operational errors

---

### Repository Structure Scaffold
**Language**: Bash
**Category**: Project Setup
**Dependencies**: mkdir, touch
**Related Pattern**: Repository Structure Pattern

**Description**: Creates recommended project directory structure

**Usage**: Run once when starting new project

**Code**:
```bash
#!/bin/bash
# create-project-structure.sh

PROJECT_NAME=${1:-my-project}

echo "Creating project structure for: $PROJECT_NAME"

mkdir -p "$PROJECT_NAME"/{src,tests,docs,.claude}
mkdir -p "$PROJECT_NAME"/src/{core,features,shared,infrastructure}
mkdir -p "$PROJECT_NAME"/tests/{unit,integration,e2e}
mkdir -p "$PROJECT_NAME"/docs/{architecture,api,guides}
mkdir -p "$PROJECT_NAME"/.claude/{memory-bank,agents,skills,rules,hooks,logs}

# Create placeholder files
touch "$PROJECT_NAME"/src/core/.gitkeep
touch "$PROJECT_NAME"/src/features/.gitkeep
touch "$PROJECT_NAME"/src/shared/.gitkeep
touch "$PROJECT_NAME"/src/infrastructure/.gitkeep
touch "$PROJECT_NAME"/tests/unit/.gitkeep
touch "$PROJECT_NAME"/tests/integration/.gitkeep
touch "$PROJECT_NAME"/tests/e2e/.gitkeep

# Create initial memory bank files
cat > "$PROJECT_NAME"/.claude/memory-bank/CLAUDE-patterns.md <<'EOF'
# Coding Patterns Library
**Last Updated**: $(date +%Y-%m-%d)

## Patterns
*Add patterns as they emerge*
EOF

cat > "$PROJECT_NAME"/.claude/memory-bank/CLAUDE-decisions.md <<'EOF'
# Architectural Decisions Log
**Last Updated**: $(date +%Y-%m-%d)

## Decisions
*Document major decisions here*
EOF

# Create .gitignore
cat > "$PROJECT_NAME"/.gitignore <<'EOF'
node_modules/
dist/
build/
.env
.env.local
*.log
.DS_Store
.claude/logs/*
.claude/backups/*
!.claude/logs/.gitkeep
!.claude/backups/.gitkeep
EOF

echo "✅ Project structure created successfully!"
echo "📁 Location: ./$PROJECT_NAME"

tree "$PROJECT_NAME" -L 3 2>/dev/null || ls -R "$PROJECT_NAME"
```

**Example**:
```bash
# Create new project
./create-project-structure.sh my-api-service

# Output:
# Creating project structure for: my-api-service
# ✅ Project structure created successfully!
# 📁 Location: ./my-api-service
```

**Customization Points**:
- Directory names (adjust to your conventions)
- Additional folders (add as needed)
- Template files (customize content)

**Gotchas**:
- Requires bash (not sh)
- Tree command optional (uses ls as fallback)
- Run from workspace root

---

### TypeScript Config (Strict Mode)
**Language**: JSON
**Category**: Configuration
**Dependencies**: TypeScript
**Related Pattern**: ADR-001 (TypeScript for All Code)

**Description**: Strict TypeScript configuration for maximum safety

**Usage**: Save as `tsconfig.json` in project root

**Code**:
```json
{
  "compilerOptions": {
    /* Language and Environment */
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "commonjs",
    "moduleResolution": "node",
    
    /* Strict Type-Checking */
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    
    /* Additional Checks */
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    
    /* Emit */
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "removeComments": true,
    
    /* Interop Constraints */
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    
    /* Skip Lib Check */
    "skipLibCheck": true,
    
    /* Path Mapping */
    "baseUrl": "./src",
    "paths": {
      "@core/*": ["core/*"],
      "@features/*": ["features/*"],
      "@shared/*": ["shared/*"],
      "@infrastructure/*": ["infrastructure/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.spec.ts"]
}
```

**Example**:
```bash
# Use in package.json
{
  "scripts": {
    "build": "tsc",
    "type-check": "tsc --noEmit",
    "dev": "ts-node-dev --respawn src/index.ts"
  }
}
```

**Customization Points**:
- `target`: Change based on runtime support
- `paths`: Adjust to your folder structure
- `lib`: Add DOM if building for browser

**Gotchas**:
- Strict mode reveals many existing issues
- Use `// @ts-expect-error` sparingly
- Path mapping requires tsconfig-paths for runtime

---

## 📦 Snippets by Category

### Error Handling (2)
- Custom Error Class (TypeScript)
- Global Error Handler (Express)

### Project Setup (2)
- Repository Structure Scaffold (Bash)
- TypeScript Config (Strict Mode)

### API Endpoints (0)
### Database Queries (0)
### Testing Utilities (0)
### Authentication (0)

---

## 💡 Snippet Requests

Snippets to add based on upcoming needs:
1. JWT authentication middleware
2. Database connection pool setup
3. Test data builders
4. API response formatter
5. Logging configuration

---

## 🔄 Snippet Evolution

| Snippet | Version | Last Updated | Uses | Success Rate |
|---------|---------|--------------|------|--------------|
| Custom Error Class | 1.0 | 2026-01-09 | 0 | N/A |
| Global Error Handler | 1.0 | 2026-01-09 | 0 | N/A |
| Repository Scaffold | 1.0 | 2026-01-09 | 1 | 100% |
| TypeScript Config | 1.0 | 2026-01-09 | 1 | 100% |

---

**Auto-Update Instructions**:
- New snippets added automatically when patterns are implemented
- Usage statistics tracked via import/reference analysis
- Snippets refined based on actual usage feedback
- Outdated snippets archived after 180 days of no usage
