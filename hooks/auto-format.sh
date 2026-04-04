#!/usr/bin/env bash
# Auto Format - Runs formatter on files after Write/Edit operations
# Runs as PostToolUse hook (non-critical: failures do not block)

set -uo pipefail

# Read hook input from stdin (required by Claude Code hook protocol)
input=$(cat)

# Extract file path from hook input
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" || ! -f "$file_path" ]]; then
  printf '%s\n' "$input"
  exit 0
fi

# Determine formatter based on file extension
ext="${file_path##*.}"

run_formatter() {
  local cmd="$1"
  shift
  if command -v "$cmd" >/dev/null 2>&1; then
    "$cmd" "$@" 2>/dev/null || true
  fi
}

case "$ext" in
  js|jsx|ts|tsx|css|scss|json|yaml|yml|md)
    run_formatter prettier --write "$file_path"
    ;;
  py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$file_path" 2>/dev/null || true
    else
      run_formatter black --quiet "$file_path"
    fi
    ;;
  rs)
    run_formatter rustfmt "$file_path"
    ;;
  go)
    run_formatter gofmt -w "$file_path"
    ;;
esac

# Pass through the original input
printf '%s\n' "$input"
exit 0
