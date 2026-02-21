---
description: Generate boilerplate files for common patterns. Use when the user asks to "scaffold", "generate boilerplate", "create a component", "create an API route", "create a test file", or "stub out" code.
argument-hint: "<type> <name> [--path dir]"
allowed-tools: "Read, Write, Glob, Grep, Bash"
---

# Scaffold

Generate boilerplate for the requested pattern. Detect the project's tech stack first and adapt the template accordingly.

## Arguments

- `$1` — **type**: One of `component`, `route`, `test`, `hook`, `model`, `service`, `middleware`
- `$2` — **name**: The name for the generated file (e.g., `UserProfile`, `auth`, `payment`)
- `--path` — Optional target directory (defaults to conventional location)

## Steps

1. **Detect project stack** by checking manifest files (package.json, pyproject.toml, go.mod, etc.)
   - Identify framework: React, Next.js, Vue, Express, FastAPI, Django, Go, etc.
   - Identify language: TypeScript vs JavaScript, Python version, etc.
   - Check for existing patterns in the codebase to match style

2. **Determine conventions** by examining 1-2 existing files of the same type:
   - Import style (named vs default exports)
   - File naming (PascalCase, kebab-case, snake_case)
   - Directory structure (co-located tests, barrel exports)
   - Formatting (tabs vs spaces, semicolons, quotes)

3. **Generate the file** based on type:

### `component`
- React/Vue/Svelte component with props interface
- Co-located test file if project uses co-location
- CSS module or styled-components stub if used in project

### `route`
- Next.js: app router or pages router route (detect which is used)
- Express: route handler with request/response typing
- FastAPI: endpoint with Pydantic model
- Go: HTTP handler with proper error handling

### `test`
- Match the project's test framework (Jest, Vitest, Pytest, Go testing)
- Import the target module
- Create describe/it blocks with placeholder assertions
- Add common test patterns (setup, teardown, mocks)

### `hook` (React)
- Custom hook with TypeScript types
- Return value structure
- JSDoc comment

### `model`
- ORM model (Prisma, SQLAlchemy, GORM, etc.)
- Or plain type/interface if no ORM detected

### `service`
- Service class or module with dependency injection pattern
- Error handling matching project conventions

### `middleware`
- Framework-appropriate middleware (Express, Django, Go)
- Request/response lifecycle handling

4. **Present what was created:**
   ```
   Created:
   - src/components/UserProfile.tsx
   - src/components/UserProfile.test.tsx

   Next steps:
   - Add component logic
   - Import in parent component
   ```

## If type is not recognized

List the available types and ask the user to pick one:
> Available scaffold types: `component`, `route`, `test`, `hook`, `model`, `service`, `middleware`

## If project stack can't be detected

Ask the user what framework and language they're using before generating.
