#!/usr/bin/env bash
# Shared utilities for task-manager plugin
set -euo pipefail

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

  shopt -s nullglob
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
get_frontmatter() {
  local file="$1"
  local key="$2"
  sed -n '/^---$/,/^---$/p' "$file" | grep "^${key}:" | sed "s/^${key}:[[:space:]]*//"
}

# Get task title from first H1 heading
get_task_title() {
  local file="$1"
  sed -n '/^---$/,/^---$/d; /^# /{s/^# //;p;q;}' "$file"
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
