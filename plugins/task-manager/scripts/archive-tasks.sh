#!/usr/bin/env bash
# Archive completed tasks older than N days to done/archive/YYYY-MM/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

tasks_dir="$(get_tasks_dir)"
done_dir="${tasks_dir}/done"

if [[ ! -d "$done_dir" ]]; then
  echo "No done/ directory found."
  exit 0
fi

# Read archive threshold from config (default: 30 days)
archive_days="$(read_config "archive_after_days" "30")"

if [[ "$archive_days" -eq 0 ]]; then
  echo "Archiving disabled (archive_after_days=0)."
  exit 0
fi

# Calculate threshold date (YYYY-MM-DD)
# macOS date uses -v flag, GNU date uses -d flag
if date -v-1d >/dev/null 2>&1; then
  # macOS
  threshold="$(date -v-"${archive_days}"d +%Y-%m-%d)"
else
  # GNU/Linux
  threshold="$(date -d "${archive_days} days ago" +%Y-%m-%d)"
fi

archived=0

for f in "${done_dir}/"*.md; do
  [[ ! -f "$f" ]] && continue

  # Read the updated date from frontmatter (semantic completion date)
  updated="$(get_frontmatter "$f" "updated")"
  [[ -z "$updated" ]] && continue

  # Compare dates lexicographically (YYYY-MM-DD format sorts correctly)
  if [[ "$updated" < "$threshold" || "$updated" == "$threshold" ]]; then
    # Determine archive subdirectory from the task's updated month
    archive_month="${updated:0:7}"  # YYYY-MM
    archive_dir="${done_dir}/archive/${archive_month}"
    mkdir -p "$archive_dir"

    # Move (prefer git mv if in a repo)
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git mv "$f" "$archive_dir/" 2>/dev/null || mv "$f" "$archive_dir/"
    else
      mv "$f" "$archive_dir/"
    fi

    (( archived++ )) || true
    echo "Archived: $(basename "$f") → archive/${archive_month}/"
  fi
done

if [[ "$archived" -eq 0 ]]; then
  echo "No tasks old enough to archive (threshold: ${archive_days} days)."
else
  echo "Archived ${archived} task(s)."
  # Regenerate TODO.md to reflect the changes
  bash "${SCRIPT_DIR}/generate-todo.sh"
fi
