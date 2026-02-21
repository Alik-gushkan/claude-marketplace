---
description: Use when the user asks to "summarize this project", "what is this codebase", "give me context", "quick context", "project overview", "what tech stack", or when starting work on an unfamiliar codebase. Produces a concise project summary covering tech stack, structure, key files, and recent changes.
argument-hint: "[directory-path]"
allowed-tools: "Read, Glob, Grep, Bash"
---

# Quick Context

Generate a concise project summary for the current working directory (or `$ARGUMENTS` if provided).

## Steps

1. **Detect project type and tech stack**
   - Look for package.json, Cargo.toml, go.mod, pyproject.toml, Gemfile, pom.xml, build.gradle, composer.json, or similar manifest files
   - Read the manifest to identify: language, framework, dependencies, scripts
   - Check for .tool-versions, .nvmrc, .python-version for runtime versions

2. **Map the directory structure**
   - Run `tree -L 2 -I 'node_modules|.git|dist|build|__pycache__|.next|target|vendor' --dirsfirst` to get an overview
   - Identify source directories, test directories, config files, CI/CD setup

3. **Identify key files**
   - Read README.md (first 50 lines) if it exists
   - Check for CLAUDE.md, .claude/ directory, Dockerfile, docker-compose.yml
   - Look for entry points: src/index.*, src/main.*, app.*, manage.py, main.go

4. **Check recent activity**
   - Run `git log --oneline -10 --no-decorate` to see recent commits
   - Run `git diff --stat HEAD~5..HEAD 2>/dev/null` to see recently changed files

5. **Present the summary** in this format:

```
## Project: [name from manifest or directory]

**Tech Stack:** [language] + [framework] | [package manager] | [runtime version]
**Type:** [web app / CLI / library / API / monorepo / etc.]

### Structure
[tree output, annotated with purpose of key directories]

### Key Files
- `[path]` — [purpose]
- `[path]` — [purpose]

### Dependencies (Notable)
- [key deps with brief purpose]

### Recent Activity
[last 5 commits, one line each]

### Notes
[anything unusual: monorepo setup, custom build system, CLAUDE.md conventions, etc.]
```

6. Keep the summary under 40 lines. Prioritize signal over completeness.
