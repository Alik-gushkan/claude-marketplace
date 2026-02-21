#!/usr/bin/env bash
# Regenerate TODO.md from task files
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

tasks_dir="$(get_tasks_dir)"

if [[ ! -d "$tasks_dir" ]]; then
  echo "No tasks directory found. Run init-tasks.sh first."
  exit 1
fi

# Build a section for a given status directory
build_section() {
  local dir="$1"
  local status_name="$2"
  local checkbox="$3"
  local count
  count="$(count_tasks "$dir")"

  echo "## ${status_name} (${count})"
  echo ""

  if [[ "$count" -eq 0 ]]; then
    echo "_No tasks._"
    echo ""
    return
  fi

  shopt -s nullglob
  for f in "$dir"/*.md; do
    local id
    id="$(get_frontmatter "$f" "id")"
    local title
    title="$(get_task_title "$f")"
    local priority
    priority="$(get_frontmatter "$f" "priority")"
    local tags
    tags="$(get_frontmatter "$f" "tags" | tr -d '[]' | tr ',' '\n' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed '/^$/d' | sed 's/^/`#/' | sed 's/$/`/' | tr '\n' ' ')"

    local line="- [${checkbox}] **${id}** ${title}"
    [[ -n "$priority" ]] && line="${line} \`${priority}\`"
    [[ -n "$tags" ]] && line="${line} ${tags}"

    echo "$line"
  done
  echo ""
}

# Generate TODO.md
{
  echo "# TODO"
  echo ""
  echo "> Auto-generated from \`.claude/tasks/\` — do not edit manually."
  echo "> Regenerate with: \`bash \${CLAUDE_PLUGIN_ROOT}/scripts/generate-todo.sh\`"
  echo ""

  build_section "${tasks_dir}/in-progress" "In Progress" " "
  build_section "${tasks_dir}/backlog" "Backlog" " "
  build_section "${tasks_dir}/ideas" "Ideas" " "
  build_section "${tasks_dir}/done" "Done" "x"
} > "${tasks_dir}/TODO.md"

echo "Regenerated ${tasks_dir}/TODO.md"
