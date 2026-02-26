#!/usr/bin/env bash
# PostToolUse hook: auto-regenerate TODO.md when a task file is modified
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read stdin (PostToolUse JSON payload)
input="$(cat)"

# Extract the file path from the tool input
# Write tool: .tool_input.file_path
# Edit tool: .tool_input.file_path
file_path="$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

# If no file path found, nothing to do
if [[ -z "$file_path" ]]; then
  echo '{}'
  exit 0
fi

# Only act on files inside .claude/tasks/
case "$file_path" in
  */.claude/tasks/*)
    ;;
  *)
    echo '{}'
    exit 0
    ;;
esac

# CRITICAL: Skip if the modified file is TODO.md itself (prevents infinite loop)
case "$file_path" in
  */TODO.md)
    echo '{}'
    exit 0
    ;;
esac

# Regenerate TODO.md
bash "${SCRIPT_DIR}/../scripts/generate-todo.sh" >/dev/null 2>&1 || true

echo '{}'
exit 0
