---
description: Create a new task
allowed-tools: Read, Write, Bash(bash:*), AskUserQuestion, Skill
argument-hint: [title]
---

# Create New Task

## Context

Existing task directories: !`ls .claude/tasks/ 2>/dev/null || echo "NOT INITIALIZED"`

## Instructions

Create a new task file in `.claude/tasks/`.

**First**, activate the `task-management` skill using the Skill tool to load the full conventions.

**If `.claude/tasks/` does not exist**, initialize it first:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-tasks.sh
```

**If $ARGUMENTS is provided**, use it as the task title and ask the user for remaining details.

**If no arguments**, ask the user what task to create.

### Gather Task Details

Use AskUserQuestion to collect:

1. **Type**: Feature (FEAT), Task (TASK), Bug (BUG), or Idea (IDEA)
2. **Priority**: critical, high, medium, or low
3. **Initial status**: backlog or ideas (default: backlog)

The title can come from $ARGUMENTS or the user's response.

### Create the Task

1. Determine the next available ID by scanning existing files:
   ```bash
   source ${CLAUDE_PLUGIN_ROOT}/scripts/utils.sh && next_id FEAT
   ```
2. Generate the slug from the title (kebab-case, 2-5 words)
3. Write the task file to the appropriate status directory
4. Follow the format from the task-management skill conventions
5. Regenerate TODO.md:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/generate-todo.sh
   ```

### After Creation

Show the user:
- The created file path
- The task ID assigned
- A brief summary of the task
