#!/usr/bin/env bash
# Initialize .claude/tasks/ directory structure in a project
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

tasks_dir="$(get_tasks_dir)"

if [[ -d "$tasks_dir" ]]; then
  echo "Tasks directory already exists at ${tasks_dir}"
  exit 0
fi

mkdir -p "${tasks_dir}"/{backlog,in-progress,done,ideas}

cat > "${tasks_dir}/TODO.md" << 'EOF'
# TODO

> Auto-generated from `.claude/tasks/` — manage tasks with the task-manager plugin.

## In Progress (0)

_No tasks in progress._

## Backlog (0)

_No tasks in the backlog._

## Ideas (0)

_No ideas yet._

## Done (0)

_Nothing completed yet._
EOF

echo "Initialized tasks directory at ${tasks_dir}"
echo "Created: backlog/ in-progress/ done/ ideas/ TODO.md"
