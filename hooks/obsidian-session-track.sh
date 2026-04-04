#!/usr/bin/env bash
# Obsidian Session Track — Collect edit events for session summary
# Runs as PostToolUse hook for Write/Edit/MultiEdit (async)
# State is scoped per-session via CLAUDE_SESSION_ID to prevent data mixing

set -uo pipefail

VAULT="$HOME/Developer/obsidian"
[[ -d "$VAULT" ]] || exit 0

input=$(cat)

# Use session ID for per-session state isolation
session_id="${CLAUDE_SESSION_ID:-$$}"
state_dir="$HOME/.claude/state/obsidian"
state_file="$state_dir/session-${session_id}.jsonl"

# Fail explicitly if state dir cannot be created (prevents silent tracking loss)
if ! mkdir -p "$state_dir" 2>/dev/null; then
  echo "obsidian-session-track: cannot create state dir: $state_dir" >&2
  printf '%s\n' "$input"
  exit 0
fi
chmod 700 "$state_dir" 2>/dev/null || true

# Only track file edits (Bash tracking removed per review: unused by stop hook)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
if [[ -n "$file_path" ]]; then
  # Use jq for safe JSON encoding (prevents injection from special chars in paths)
  jq -nc --arg f "$file_path" --arg t "$(date +%H:%M:%S)" \
    '{type:"edit",file:$f,ts:$t}' >> "$state_file" 2>/dev/null || true
fi

# Pass through
printf '%s\n' "$input"
exit 0
