#!/usr/bin/env bash
# Shared utilities for task-manager plugin
#
# Compatibility: macOS bash 3.2+, Linux bash 4+
# Note: shopt -s nullglob is bash-specific. These scripts MUST run
# under bash (not zsh). Use /bin/bash or env bash explicitly.
set -euo pipefail

# Enable nullglob once at source-time so glob patterns that match
# nothing expand to empty instead of the literal pattern.
shopt -s nullglob

TASKS_DIR=".claude/tasks"

# Get the project tasks directory
get_tasks_dir() {
  local project_dir="${CLAUDE_PROJECT_DIR:-.}"
  echo "${project_dir}/${TASKS_DIR}"
}

# Check if tasks directory exists
tasks_initialized() {
  local tasks_dir
  tasks_dir="$(get_tasks_dir)"
  [[ -d "$tasks_dir" ]]
}

# Get the next available ID for a given type prefix
# Usage: next_id FEAT -> FEAT-004
next_id() {
  local prefix="$1"
  local tasks_dir
  tasks_dir="$(get_tasks_dir)"
  local max=0

  for dir in "$tasks_dir"/backlog "$tasks_dir"/in-progress "$tasks_dir"/done "$tasks_dir"/ideas; do
    for f in "$dir"/"${prefix}"-*.md; do
      local basename
      basename="$(basename "$f")"
      local num
      num="$(echo "$basename" | sed -n "s/^${prefix}-\([0-9]*\)_.*/\1/p")"
      if [[ -n "$num" ]] && (( 10#$num > max )); then
        max=$((10#$num))
      fi
    done
  done

  printf "%s-%03d" "$prefix" $((max + 1))
}

# Extract YAML frontmatter value from a task file
# Usage: get_frontmatter "file.md" "priority"
# Returns empty string if key not found (grep exit 1 is suppressed)
# Note: tr -d '\r' handles CRLF line endings (Write tool on some systems)
get_frontmatter() {
  local file="$1"
  local key="$2"
  tr -d '\r' < "$file" | sed -n '/^---$/,/^---$/p' | grep "^${key}:" | sed "s/^${key}:[[:space:]]*//" || true
}

# Get task title from first H1 heading
get_task_title() {
  local file="$1"
  tr -d '\r' < "$file" | sed -n '/^---$/,/^---$/d; /^# /{s/^# //;p;q;}'
}

# Count tasks in a status directory
count_tasks() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    find "$dir" -name "*.md" -maxdepth 1 2>/dev/null | wc -l | tr -d ' '
  else
    echo "0"
  fi
}

# Read a config value from .claude/task-manager.local.md
# Usage: read_config "context_mode" "smart"
# Returns the value if found, or the default (second arg) if not
read_config() {
  local key="$1"
  local default="${2:-}"
  local project_dir="${CLAUDE_PROJECT_DIR:-.}"
  local config_file="${project_dir}/.claude/task-manager.local.md"

  if [[ -f "$config_file" ]]; then
    local val
    val="$(get_frontmatter "$config_file" "$key")"
    if [[ -n "$val" ]]; then
      printf '%s' "$val"
      return
    fi
  fi
  printf '%s' "$default"
}

# Escape string for JSON output
escape_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}
