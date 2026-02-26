# Per-Project Configuration

The task-manager plugin supports per-project configuration via `.claude/task-manager.local.md`. This file uses YAML frontmatter (same format as task files) and should be gitignored since it contains local preferences.

## Config File Location

```
<project-root>/.claude/task-manager.local.md
```

## Schema

```yaml
---
default_priority: medium        # Default priority for new tasks: critical | high | medium | low
default_type: task              # Default task type: feature | task | bug | idea
auto_init: true                 # Auto-create .claude/tasks/ on first session (true | false)
context_mode: smart             # Session context injection mode: smart | full | minimal
context_max_items: 10           # Max items shown in smart mode
auto_tags: []                   # Tags auto-applied to new tasks (e.g., [webapp, frontend])
archive_after_days: 30          # Move done tasks to archive after N days (0 = disabled)
---
```

## Field Reference

### `default_priority`
Priority assigned to new tasks when the user doesn't specify one. Default: `medium`.

### `default_type`
Task type used when creating tasks without specifying a type. Default: `task`.

### `auto_init`
When `true`, the SessionStart hook automatically creates `.claude/tasks/` if it doesn't exist. When `false`, the user must explicitly initialize. Default: `true`.

### `context_mode`
Controls how much task information is injected into the session context at startup.

| Mode | What's Injected | Best For |
|------|----------------|----------|
| `smart` | In-progress tasks (full), high/critical backlog (summary), counts | Most projects |
| `full` | Entire TODO.md as-is | Small projects (<10 tasks) |
| `minimal` | Summary counts only (e.g., "3 in-progress, 7 backlog") | Large projects, context-sensitive work |

Default: `smart`.

### `context_max_items`
Maximum number of individual tasks shown in `smart` mode context. Tasks beyond this limit are represented as counts. Default: `10`.

### `auto_tags`
Tags automatically added to every new task in this project. Useful for multi-project workspaces. Default: `[]`.

### `archive_after_days`
Number of days after which completed tasks are moved from `done/` to `done/archive/YYYY-MM/`. Set to `0` to disable archiving. Default: `30`.

## How Scripts Read Config

All plugin scripts use the `read_config` helper from `utils.sh`:

```bash
source ${CLAUDE_PLUGIN_ROOT}/scripts/utils.sh

# Read a config value with fallback default
mode=$(read_config "context_mode" "smart")
max=$(read_config "context_max_items" "10")
```

The helper reads YAML frontmatter from the config file using the same parser as task frontmatter. Missing keys return the provided default value.

## Example Config

```yaml
---
default_priority: high
default_type: feature
auto_init: true
context_mode: smart
context_max_items: 15
auto_tags: [webapp, react]
archive_after_days: 14
---

# Project Task Config

Optional notes about project-specific task conventions can go here.
```
