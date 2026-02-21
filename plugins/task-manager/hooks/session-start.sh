#!/usr/bin/env bash
# SessionStart hook: reads .claude/tasks/TODO.md and injects as context
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../scripts/utils.sh"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
TODO_FILE="${PROJECT_DIR}/.claude/tasks/TODO.md"

# If no tasks directory, exit silently (plugin not initialized for this project)
if [[ ! -f "$TODO_FILE" ]]; then
  echo '{}'
  exit 0
fi

# Read TODO.md content
todo_content="$(cat "$TODO_FILE")"
escaped="$(escape_json "$todo_content")"

context="Project Tasks (from .claude/tasks/TODO.md):\n${escaped}\n\nUse the task-management skill for task operations. Run /tasks for details."

cat <<EOF
{
  "additional_context": "${context}",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${context}"
  }
}
EOF

exit 0
