# task-manager

Persistent, version-controlled task management for Claude Code. Track features, bugs, and ideas as markdown files in `.claude/tasks/`, organized by status directories.

## Features

- **Directory = Status** — `backlog/`, `in-progress/`, `done/`, `ideas/` directories. Moving files = changing status. Clean `git mv` diffs.
- **Auto-generated TODO.md** — overview index regenerated from task files
- **Session context injection** — SessionStart hook reads TODO.md so Claude knows your tasks
- **Slash commands** — `/tasks` to view, `/task-add` to create
- **Skill guidance** — task-management skill teaches Claude the conventions

## Per-Project Structure

```
.claude/tasks/
├── TODO.md                         # Auto-generated overview
├── backlog/
│   └── FEAT-001_cmd-k-palette.md
├── in-progress/
│   └── TASK-002_frontend-crud.md
├── done/
│   └── FEAT-000_models-migrations.md
└── ideas/
    └── IDEA-001_mobile-app.md
```

## Usage

### Initialize tasks in a project

Say "initialize tasks" or run:

```bash
/task-add My first feature
```

The plugin will create `.claude/tasks/` automatically if it doesn't exist.

### View tasks

```bash
/tasks              # Show TODO.md overview
/tasks backlog      # List backlog tasks
/tasks FEAT-001     # Show specific task details
```

### Create tasks

```bash
/task-add Cmd+K command palette
```

You'll be asked for type (FEAT/TASK/BUG/IDEA) and priority.

### Manage tasks

Just ask naturally:
- "Move FEAT-001 to in-progress"
- "Complete TASK-002"
- "Add a bug for the login CSRF issue"

## Task File Format

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
Global command palette for quick navigation.

## Acceptance Criteria
- [ ] Cmd+K opens palette
- [ ] Fuzzy search works
```

## Components

| Component | Purpose |
|---|---|
| `skills/task-management/SKILL.md` | Core task management conventions |
| `commands/tasks.md` | `/tasks` — list and view tasks |
| `commands/task-add.md` | `/task-add` — create new task |
| `hooks/session-start.sh` | Inject TODO.md at session start |
| `scripts/init-tasks.sh` | Initialize `.claude/tasks/` structure |
| `scripts/generate-todo.sh` | Regenerate TODO.md from files |

## License

MIT
