---
name: task-management
description: This skill should be used when the user asks to "add a task", "create a task", "complete a task", "move a task", "check task status", "list tasks", "manage tasks", "update backlog", "track progress", or mentions todo items, backlog, in-progress items, or task management. Provides persistent, version-controlled task management using markdown files in .claude/tasks/.
---

# Task Management

Manage development tasks as individual markdown files in `.claude/tasks/`, organized by status directories. Each task has YAML frontmatter for metadata and markdown body for details. A generated `TODO.md` provides the overview.

## Directory Structure

```
.claude/tasks/
├── TODO.md              # Auto-generated overview (do not edit manually)
├── backlog/             # Planned work not yet started
├── in-progress/         # Currently active work
├── done/                # Completed tasks
└── ideas/               # Future possibilities, low priority
```

**Directory = Status.** Moving a file between directories changes its status. This produces clean `git mv` diffs.

## Initialization

Run the init script once per project before the first task operation. The script is idempotent:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-tasks.sh
```

If `.claude/tasks/` already exists, the script exits cleanly.

## Task File Format

Each task is a markdown file named `TYPE-NNN_slug.md` in its status directory.

### File Naming

| Type | Prefix | Example |
|------|--------|---------|
| Feature | `FEAT` | `FEAT-001_cmd-k-palette.md` |
| Task | `TASK` | `TASK-012_fix-auth-redirect.md` |
| Bug | `BUG` | `BUG-003_login-csrf-error.md` |
| Idea | `IDEA` | `IDEA-007_ai-time-estimates.md` |

### Frontmatter Schema

```yaml
---
id: FEAT-001
type: feature       # feature | task | bug | idea
priority: high      # critical | high | medium | low
tags: [ui, ux]
created: 2026-02-22
updated: 2026-02-22
---
```

### Body Structure

```markdown
# Task Title

## Description
What needs to be done and why.

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Notes
Implementation notes, links, or context.
```

For the complete format specification and advanced patterns, consult `references/conventions.md`.

## Core Operations

### Creating a Task

1. Determine the type prefix (FEAT, TASK, BUG, IDEA)
2. Calculate the next available ID using the utility script
3. Create the file in the appropriate status directory (usually `backlog/` or `ideas/`)
4. Write frontmatter + body following the format above
5. Regenerate TODO.md

To get the next ID programmatically:
```bash
source ${CLAUDE_PLUGIN_ROOT}/scripts/utils.sh
next_id FEAT  # Returns e.g. FEAT-004
```

### Moving a Task (Status Change)

Move the file between directories using `git mv` for clean version control:

```bash
git mv .claude/tasks/backlog/FEAT-001_cmd-k-palette.md .claude/tasks/in-progress/
```

Then regenerate TODO.md. Common transitions:
- `backlog/` → `in-progress/` (starting work)
- `in-progress/` → `done/` (completing work)
- `ideas/` → `backlog/` (promoting an idea)
- `in-progress/` → `backlog/` (pausing work)

### Completing a Task

1. Move file to `done/`: `git mv .claude/tasks/in-progress/FEAT-001_*.md .claude/tasks/done/`
2. Update the `updated` date in frontmatter
3. Check all acceptance criteria boxes `[x]`
4. Regenerate TODO.md

### Viewing Tasks

Read `.claude/tasks/TODO.md` for the overview. For details on a specific task, read the individual file.

To find a task by ID:
```bash
find .claude/tasks -name "FEAT-001_*" -type f
```

### Deleting a Task

Delete the file and regenerate TODO.md:

```bash
rm .claude/tasks/backlog/FEAT-001_cmd-k-palette.md
bash ${CLAUDE_PLUGIN_ROOT}/scripts/generate-todo.sh
```

### Regenerating TODO.md

After any task changes, regenerate the overview:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/generate-todo.sh
```

This rebuilds `TODO.md` from all task files, grouped by status with counts.

## Workflow Integration

### At Session Start

The SessionStart hook automatically reads `TODO.md` and injects it as context. This provides awareness of current project tasks without manual loading.

### During Development

When completing work related to a task:
1. Read the task file for acceptance criteria
2. After work is done, check off completed criteria
3. When all criteria are met, move to `done/`
4. Regenerate TODO.md

### With Git

Commit task files alongside related code changes:
- Task creation → commit with the task file
- Status changes → commit the `git mv`
- Completion → commit with updated criteria and TODO.md

## Priority Ordering

Within each status directory, tasks are displayed in file-system order. Use priority frontmatter for importance:

| Priority | When to use |
|----------|-------------|
| `critical` | Blocking other work, needs immediate attention |
| `high` | Important, should be done soon |
| `medium` | Normal priority, planned work |
| `low` | Nice to have, no urgency |

## Additional Resources

### Reference Files

For detailed conventions and advanced patterns:
- **`references/conventions.md`** — Complete format specification, tag conventions, advanced frontmatter fields, and examples

### Utility Scripts (at plugin root)

`${CLAUDE_PLUGIN_ROOT}` is set automatically by the Claude Code plugin runtime. These scripts live at the plugin root, not inside the skill directory:

- **`${CLAUDE_PLUGIN_ROOT}/scripts/init-tasks.sh`** — Initialize `.claude/tasks/` directory structure
- **`${CLAUDE_PLUGIN_ROOT}/scripts/generate-todo.sh`** — Regenerate `TODO.md` from task files
- **`${CLAUDE_PLUGIN_ROOT}/scripts/utils.sh`** — Shared helpers (next_id, frontmatter parsing, JSON escaping)
