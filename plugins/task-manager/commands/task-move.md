---
description: Move a task to a different status
allowed-tools: Read, Write, Edit, Bash(bash:*), Glob, Grep
argument-hint: <task-id> <target-status>
---

# Move Task

## Context

Task directories: !`ls .claude/tasks/ 2>/dev/null || echo "NOT INITIALIZED"`

## Instructions

Move a task file between status directories in `.claude/tasks/`.

**First**, activate the `task-management` skill using the Skill tool to load the full conventions.

**If `.claude/tasks/` does not exist**, tell the user: "No tasks found. Use /task-add to create your first task." and stop.

### Parse Arguments

`$ARGUMENTS` should contain a task ID and target status, e.g.:
- `/task-move FEAT-001 in-progress`
- `/task-move BUG-003 done`
- `/task-move TASK-005 backlog`

**`$1`** = task ID (e.g., `FEAT-001`)
**`$2`** = target status (e.g., `in-progress`)

If arguments are missing or unclear, ask the user what to move and where.

### Validate

1. **Find the task file** — search all status directories for a file matching the task ID:
   ```bash
   find .claude/tasks -name "$1_*" -type f 2>/dev/null
   ```
   If not found, tell the user and stop.

2. **Validate target status** — must be one of: `backlog`, `in-progress`, `done`, `ideas`
   If invalid, show valid options and stop.

3. **Check if already there** — if the task is already in the target directory, tell the user and stop.

### Move the Task

1. Use `git mv` to move the file to the target status directory:
   ```bash
   git mv .claude/tasks/<current-status>/<filename> .claude/tasks/<target-status>/
   ```
   If not in a git repo, fall back to regular `mv`.

2. Update the `updated:` date in the task file's frontmatter to today's date.

3. If moving to `done/`, check the acceptance criteria in the task body. If there are unchecked items `[ ]`, warn the user but proceed.

4. Regenerate TODO.md:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/generate-todo.sh
   ```

### After Moving

Confirm to the user:
- "Moved **TASK-ID** from `<old-status>` to `<new-status>`"
- Show updated counts if relevant
