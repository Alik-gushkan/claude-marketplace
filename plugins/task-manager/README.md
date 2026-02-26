# task-manager

Persistent, version-controlled task management for Claude Code. Track features, bugs, and ideas as markdown files in `.claude/tasks/`, organized by status directories.

## Features

- **Directory = Status** — `backlog/`, `in-progress/`, `done/`, `ideas/` directories. Moving files = changing status. Clean `git mv` diffs.
- **Smart context injection** — SessionStart hook injects relevant tasks based on configurable mode (smart/full/minimal). Smart mode shows in-progress details + high-priority backlog summaries.
- **Auto-initialization** — Tasks directory is created automatically on first session start. No manual setup required.
- **Auto-generated TODO.md** — Overview index regenerated from task files, automatically updated when tasks change.
- **Slash commands** — `/tasks` to view, `/task-add` to create, `/task-move` to change status
- **Task archiving** — Completed tasks archived after configurable days to keep directories clean.
- **Per-project config** — Tune behavior per-project via `.claude/task-manager.local.md`
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
│   ├── FEAT-000_models-migrations.md
│   └── archive/                    # Archived completed tasks
│       └── 2026-01/
└── ideas/
    └── IDEA-001_mobile-app.md
```

## Usage

### Initialize tasks in a project

Say "initialize tasks" or run:

```bash
/task-add My first feature
```

The plugin auto-creates `.claude/tasks/` if it doesn't exist.

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

### Move tasks

```bash
/task-move FEAT-001 in-progress    # Start working
/task-move BUG-003 done            # Complete
/task-move TASK-005 backlog        # Pause work
```

### Manage tasks

Just ask naturally:
- "Move FEAT-001 to in-progress"
- "Complete TASK-002"
- "Add a bug for the login CSRF issue"

### Archive old tasks

Completed tasks older than 30 days (configurable) can be archived:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/archive-tasks.sh
```

## Configuration

Create `.claude/task-manager.local.md` in your project root (gitignore recommended):

```yaml
---
default_priority: medium
default_type: task
auto_init: true
context_mode: smart
context_max_items: 10
auto_tags: []
archive_after_days: 30
---
```

See `skills/task-management/references/config-schema.md` for full field documentation.

### Context Modes

| Mode | What's Injected | Best For |
|------|----------------|----------|
| `smart` (default) | In-progress (full detail) + high/critical backlog (title only) + counts | Most projects |
| `full` | Entire TODO.md as-is | Small projects (<10 tasks) |
| `minimal` | Summary counts only | Large projects |

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
| `commands/task-move.md` | `/task-move` — move task between statuses |
| `hooks/session-start.sh` | Smart context injection at session start |
| `hooks/post-task-write.sh` | Auto-regenerate TODO.md on task edits |
| `scripts/init-tasks.sh` | Initialize `.claude/tasks/` structure |
| `scripts/generate-todo.sh` | Regenerate TODO.md from files |
| `scripts/archive-tasks.sh` | Archive old completed tasks |
| `scripts/utils.sh` | Shared helpers (ID gen, parsing, config) |

## License

MIT
