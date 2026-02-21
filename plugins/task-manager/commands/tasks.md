---
description: List and view project tasks
allowed-tools: Read, Glob, Grep, Bash(bash:*), Bash(find:*), Bash(cat:*)
argument-hint: [status|task-id]
---

# Task Overview

Current tasks directory: !`ls -d .claude/tasks/ 2>/dev/null && echo "initialized" || echo "NOT INITIALIZED"`

## Context

Current TODO overview:
!`cat .claude/tasks/TODO.md 2>/dev/null || echo "No tasks found. Initialize with: bash \${CLAUDE_PLUGIN_ROOT}/scripts/init-tasks.sh"`

## Instructions

Display the project's task overview to the user.

If $ARGUMENTS is provided:
- If it matches a status name (`backlog`, `in-progress`, `done`, `ideas`): list all tasks in that status directory with their titles and priorities
- If it matches a task ID pattern (e.g., `FEAT-001`): find and display the full task file contents

If no arguments, display the TODO.md overview in a clean, readable format.

If `.claude/tasks/` does not exist, offer to initialize it by running:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-tasks.sh
```

After displaying tasks, briefly mention available actions:
- `/task-add` to create a new task
- Ask to "move task FEAT-001 to in-progress" to change status
- Ask to "complete FEAT-001" to mark as done
