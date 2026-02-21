# Task Conventions Reference

## Complete Frontmatter Schema

```yaml
---
id: FEAT-001                    # Required. TYPE-NNN format
type: feature                   # Required. feature | task | bug | idea
priority: high                  # Required. critical | high | medium | low
tags: [ui, ux, accessibility]   # Optional. Categorization tags
created: 2026-02-22             # Required. ISO date
updated: 2026-02-22             # Required. ISO date, update on changes
blocked_by: TASK-003            # Optional. ID of blocking task
related: [FEAT-002, BUG-001]   # Optional. Related task IDs
estimate: 2d                    # Optional. Time estimate (h=hours, d=days)
---
```

## Type Prefixes

| Prefix | Type | Description |
|--------|------|-------------|
| `FEAT` | Feature | New functionality or capability |
| `TASK` | Task | Technical work, refactoring, infrastructure |
| `BUG` | Bug | Defect or incorrect behavior to fix |
| `IDEA` | Idea | Future possibility, needs exploration |

## File Naming Rules

- Format: `TYPE-NNN_short-slug.md`
- Slug: kebab-case, 2-5 words, descriptive
- Numbers: zero-padded to 3 digits (001-999)
- Examples:
  - `FEAT-001_cmd-k-palette.md`
  - `BUG-012_csrf-token-expired.md`
  - `TASK-003_migrate-to-react-19.md`
  - `IDEA-001_ai-time-estimates.md`

## Complete Task File Template

```markdown
---
id: FEAT-001
type: feature
priority: high
tags: [ui, keyboard]
created: 2026-02-22
updated: 2026-02-22
---

# Cmd+K Command Palette

## Description

Add a global command palette triggered by Cmd+K that allows quick navigation
and action execution across the application. This is a core UX improvement
that reduces mouse dependency and speeds up common workflows.

## Acceptance Criteria

- [ ] Cmd+K keyboard shortcut opens the palette overlay
- [ ] Fuzzy search filters available commands in real-time
- [ ] Enter executes the selected command
- [ ] Escape closes the palette
- [ ] Recent commands shown by default (last 5)
- [ ] Accessible: focus trap, aria labels, screen reader support

## Technical Notes

- Use cmdk library (https://cmdk.paco.me/) for the palette component
- Commands registered via a central registry pattern
- Keyboard shortcut handled at the app layout level

## Related

- FEAT-002: Keyboard-first navigation (depends on this)
```

## Tag Conventions

Use lowercase, single-word or hyphenated tags:

| Category | Tags |
|----------|------|
| Area | `ui`, `api`, `database`, `auth`, `infra` |
| Scope | `frontend`, `backend`, `fullstack` |
| Quality | `performance`, `security`, `accessibility`, `testing` |
| Effort | `quick-win`, `deep-work`, `spike` |

## Priority Guidelines

| Priority | Response Time | Examples |
|----------|---------------|---------|
| `critical` | Drop everything | Production bug, security vulnerability, data loss |
| `high` | This sprint/week | Core feature, blocking dependency, user-reported bug |
| `medium` | Next sprint | Planned feature, tech debt, improvement |
| `low` | Someday/maybe | Nice-to-have, exploration, polish |

## Status Transitions

```
ideas/ ──→ backlog/ ──→ in-progress/ ──→ done/
  │                         │
  │                         ↓
  └─────────────────── (deleted if abandoned)
```

Valid transitions:
- `ideas/` → `backlog/` (idea promoted to planned work)
- `backlog/` → `in-progress/` (work started)
- `in-progress/` → `done/` (work completed)
- `in-progress/` → `backlog/` (work paused/deprioritized)
- Any → deleted (task abandoned, remove file)

## Blocked Tasks

When a task is blocked by another:

1. Add `blocked_by: TASK-003` to frontmatter
2. Add a note in the body explaining the blocker
3. Keep the task in its current status directory
4. When the blocker is resolved, remove the `blocked_by` field

## TODO.md Format

The generated `TODO.md` follows this structure:

```markdown
# TODO

> Auto-generated from `.claude/tasks/` — do not edit manually.

## In Progress (N)
- [ ] **FEAT-001** Task Title `priority` `#tag1` `#tag2`

## Backlog (N)
- [ ] **TASK-002** Task Title `priority` `#tag`

## Ideas (N)
- [ ] **IDEA-001** Task Title `low`

## Done (N)
- [x] **FEAT-000** Task Title `priority`
```

Rules:
- Sections ordered: In Progress → Backlog → Ideas → Done
- Each section shows count in parentheses
- Tasks show: checkbox, bold ID, title, priority badge, tag badges
- Done tasks use `[x]` checkboxes
- Empty sections show `_No tasks._`
