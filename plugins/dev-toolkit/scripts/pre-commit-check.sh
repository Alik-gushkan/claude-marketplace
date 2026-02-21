#!/usr/bin/env bash
# Pre-commit hook: warns when committing if no test files were modified
# Receives JSON on stdin with tool_name and tool_input from Claude Code

set -euo pipefail

# Read the hook input from stdin
INPUT=$(cat)

# Extract the bash command being run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check git commit commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit'; then
  exit 0
fi

# Check if any test files are staged
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)

HAS_TESTS=false
if echo "$STAGED_FILES" | grep -qiE '(test|spec|_test)\.(ts|js|tsx|jsx|py|go|rs|rb)$'; then
  HAS_TESTS=true
fi

if [ "$HAS_TESTS" = false ]; then
  # Output a warning but don't block — let Claude decide
  cat <<'EOF'
{
  "decision": "ask",
  "reason": "No test files are staged with this commit. Consider adding tests for the changes being committed.",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "The staged changes don't include any test files. This may be intentional (docs, config changes) or an oversight. Consider whether tests should be added."
  }
}
EOF
  exit 0
fi

# Tests are included — proceed normally
exit 0
