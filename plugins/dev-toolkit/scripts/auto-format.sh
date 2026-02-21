#!/usr/bin/env bash
# Post-write/edit hook: runs the project's formatter on modified files
# Receives JSON on stdin with tool_name and tool_input from Claude Code

set -euo pipefail

INPUT=$(cat)

# Extract the file path that was written/edited
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Try to find and run the project's formatter
# Check for common formatters in order of preference

if [ -f "$(dirname "$FILE_PATH")/node_modules/.bin/prettier" ] || command -v prettier &>/dev/null; then
  case "$EXT" in
    ts|tsx|js|jsx|json|css|scss|md|html|yaml|yml)
      npx prettier --write "$FILE_PATH" 2>/dev/null && exit 0
      ;;
  esac
fi

if [ -f "pyproject.toml" ] || [ -f "setup.cfg" ]; then
  case "$EXT" in
    py)
      if command -v ruff &>/dev/null; then
        ruff format "$FILE_PATH" 2>/dev/null && exit 0
      elif command -v black &>/dev/null; then
        black --quiet "$FILE_PATH" 2>/dev/null && exit 0
      fi
      ;;
  esac
fi

if command -v gofmt &>/dev/null; then
  case "$EXT" in
    go)
      gofmt -w "$FILE_PATH" 2>/dev/null && exit 0
      ;;
  esac
fi

if command -v rustfmt &>/dev/null; then
  case "$EXT" in
    rs)
      rustfmt "$FILE_PATH" 2>/dev/null && exit 0
      ;;
  esac
fi

# No formatter found or not a recognized file type — that's fine
exit 0
