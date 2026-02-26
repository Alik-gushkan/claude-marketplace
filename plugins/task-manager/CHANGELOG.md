# Changelog

## 0.2.0 — 2026-02-26

### New Features

**Smart context injection** — Session context no longer dumps the entire TODO.md. Three modes available via `.claude/task-manager.local.md`:
- `smart` (default): In-progress tasks with full detail, high/critical backlog as summaries, aggregate counts for the rest. ~90% context reduction for large projects.
- `full`: Entire TODO.md as-is (legacy behavior).
- `minimal`: Just summary counts (e.g., "3 in-progress, 7 backlog").

**Auto-initialization** — The SessionStart hook now creates `.claude/tasks/` automatically if it doesn't exist (when `auto_init: true` in config, which is the default). No more silent `{}` responses — the hook always returns useful context or a helpful hint.

**`/task-move` command** — Dedicated command for moving tasks between statuses:
```
/task-move FEAT-001 in-progress
/task-move BUG-003 done
```
Uses `git mv` for clean diffs, updates the `updated:` date, and regenerates TODO.md.

**Auto-regenerate TODO.md** — A PostToolUse hook watches for `Write|Edit` operations on files inside `.claude/tasks/`. When a task file is modified, TODO.md is silently regenerated. Includes infinite-loop prevention (skips if the modified file is TODO.md itself).

**Task archiving** — `scripts/archive-tasks.sh` moves completed tasks from `done/` to `done/archive/YYYY-MM/` after a configurable number of days (default: 30). Keeps active directories clean while preserving history.

**Per-project configuration** — New `.claude/task-manager.local.md` config file with YAML frontmatter. Controls context mode, auto-init, default priority/type, auto-tags, archive threshold, and more. See `references/config-schema.md` for the full schema.

### Improvements

- `utils.sh`: Added `read_config()` helper for reading per-project config values with fallback defaults
- `hooks.json`: Added PostToolUse entry for Write|Edit auto-regeneration
- Session-start hook completely rewritten for reliability and configurability

### Files Added
- `commands/task-move.md` — new slash command
- `hooks/post-task-write.sh` — PostToolUse auto-regenerate hook
- `scripts/archive-tasks.sh` — task archiving script
- `skills/task-management/references/config-schema.md` — config documentation

### Files Modified
- `hooks/session-start.sh` — rewritten with auto-init + smart injection
- `hooks/hooks.json` — added PostToolUse entry
- `scripts/utils.sh` — added `read_config()` helper
- `.claude-plugin/plugin.json` — version bump to 0.2.0

---

## 0.1.0 — 2026-02-22

### Initial Release

Core task management plugin with:
- Directory-based status tracking (`backlog/`, `in-progress/`, `done/`, `ideas/`)
- Auto-generated TODO.md overview
- SessionStart hook for context injection
- `/tasks` and `/task-add` slash commands
- `task-management` skill with conventions reference
- Utility scripts for initialization, TODO regeneration, ID generation

### Patches (0.1.0)

**bash/zsh compatibility fix** — `shopt -s nullglob` moved to source-time in `utils.sh`; added `|| true` to grep pipelines to prevent exit-code-1 crashes with `set -eo pipefail`.

**CRLF line ending fix** — Added `tr -d '\r'` before sed parsing in `get_frontmatter()` and `get_task_title()` to handle CRLF files created by Claude Code's Write tool on some systems.
