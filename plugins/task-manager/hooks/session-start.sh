#!/usr/bin/env bash
# SessionStart hook: auto-init tasks, inject smart context
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../scripts/utils.sh"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
TASKS_DIR="${PROJECT_DIR}/.claude/tasks"

# --- Helper: emit JSON response ---
emit_context() {
  local context="$1"
  local escaped
  escaped="$(escape_json "$context")"
  cat <<EOF
{
  "additional_context": "${escaped}",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${escaped}"
  }
}
EOF
}

# --- Phase 1: Auto-init if tasks dir missing ---
if [[ ! -d "$TASKS_DIR" ]]; then
  auto_init="$(read_config "auto_init" "true")"
  if [[ "$auto_init" == "true" ]]; then
    bash "${SCRIPT_DIR}/../scripts/init-tasks.sh" >/dev/null 2>&1
    emit_context "Task tracking initialized for this project. Use /task-add to create your first task."
  else
    emit_context "Task tracking available. Use /task-add to start."
  fi
  exit 0
fi

# --- Phase 2: Read config ---
context_mode="$(read_config "context_mode" "smart")"
context_max_items="$(read_config "context_max_items" "10")"

# --- Phase 3: Build context based on mode ---

build_minimal_context() {
  local ip_count bp_count id_count dn_count
  ip_count="$(count_tasks "${TASKS_DIR}/in-progress")"
  bp_count="$(count_tasks "${TASKS_DIR}/backlog")"
  id_count="$(count_tasks "${TASKS_DIR}/ideas")"
  dn_count="$(count_tasks "${TASKS_DIR}/done")"

  printf "Project Tasks: %s in-progress, %s backlog, %s ideas, %s done." \
    "$ip_count" "$bp_count" "$id_count" "$dn_count"

  if [[ "$ip_count" -eq 0 && "$bp_count" -eq 0 && "$id_count" -eq 0 && "$dn_count" -eq 0 ]]; then
    printf "\nNo tasks yet. Use /task-add to create your first task."
  fi
}

build_full_context() {
  local todo_file="${TASKS_DIR}/TODO.md"
  if [[ -f "$todo_file" ]]; then
    printf "Project Tasks (from .claude/tasks/TODO.md):\n"
    cat "$todo_file"
  else
    build_minimal_context
  fi
  printf "\n\nUse the task-management skill for task operations. Run /tasks for details."
}

build_smart_context() {
  local items_shown=0
  local max_items="$context_max_items"
  local context=""

  # --- In-progress: full detail ---
  local ip_count
  ip_count="$(count_tasks "${TASKS_DIR}/in-progress")"
  if [[ "$ip_count" -gt 0 ]]; then
    context+="## In Progress (${ip_count})\n"
    for f in "${TASKS_DIR}/in-progress/"*.md; do
      [[ ! -f "$f" ]] && continue
      (( items_shown >= max_items )) && break
      local id title priority desc
      id="$(get_frontmatter "$f" "id")"
      title="$(get_task_title "$f")"
      priority="$(get_frontmatter "$f" "priority")"
      # Extract first line of Description section as summary
      desc="$(tr -d '\r' < "$f" | sed -n '/^## Description/,/^##/{/^## Description/d;/^##/d;/^$/d;p;}' | head -1)"

      context+="- **${id}** ${title}"
      [[ -n "$priority" ]] && context+=" \`${priority}\`"
      [[ -n "$desc" ]] && context+="\n  ${desc}"
      context+="\n"
      (( items_shown++ )) || true
    done
    context+="\n"
  fi

  # --- Backlog: high/critical only, title+priority ---
  local bp_count high_count=0
  bp_count="$(count_tasks "${TASKS_DIR}/backlog")"
  if [[ "$bp_count" -gt 0 ]]; then
    local backlog_lines=""
    for f in "${TASKS_DIR}/backlog/"*.md; do
      [[ ! -f "$f" ]] && continue
      (( items_shown >= max_items )) && break
      local priority
      priority="$(get_frontmatter "$f" "priority")"
      if [[ "$priority" == "critical" || "$priority" == "high" ]]; then
        local id title
        id="$(get_frontmatter "$f" "id")"
        title="$(get_task_title "$f")"
        backlog_lines+="- **${id}** ${title} \`${priority}\`\n"
        (( high_count++ )) || true
        (( items_shown++ )) || true
      fi
    done

    if [[ "$high_count" -gt 0 ]]; then
      local others=$(( bp_count - high_count ))
      context+="## Backlog — High Priority (${high_count} of ${bp_count})\n"
      context+="${backlog_lines}"
      if [[ "$others" -gt 0 ]]; then
        context+="- _...and ${others} more at medium/low priority_\n"
      fi
      context+="\n"
    else
      context+="## Backlog (${bp_count})\n"
      context+="- _${bp_count} tasks at medium/low priority_\n\n"
    fi
  fi

  # --- Ideas + Done: counts only ---
  local id_count dn_count
  id_count="$(count_tasks "${TASKS_DIR}/ideas")"
  dn_count="$(count_tasks "${TASKS_DIR}/done")"

  local summary_parts=()
  [[ "$id_count" -gt 0 ]] && summary_parts+=("${id_count} ideas")
  [[ "$dn_count" -gt 0 ]] && summary_parts+=("${dn_count} done")
  if [[ ${#summary_parts[@]} -gt 0 ]]; then
    local joined
    joined="$(IFS=', '; echo "${summary_parts[*]}")"
    context+="Also: ${joined}.\n"
  fi

  # Empty project fallback
  if [[ -z "$context" ]]; then
    context="No tasks yet. Use /task-add to create your first task."
  fi

  printf "Project Tasks:\n%b\nUse the task-management skill for task operations. Run /tasks for details." "$context"
}

# --- Dispatch ---
case "$context_mode" in
  full)
    output="$(build_full_context)"
    ;;
  minimal)
    output="$(build_minimal_context)"
    ;;
  *)
    output="$(build_smart_context)"
    ;;
esac

emit_context "$output"
exit 0
