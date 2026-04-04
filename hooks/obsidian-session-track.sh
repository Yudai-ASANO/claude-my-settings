#!/usr/bin/env bash
# Obsidian Session Track — Collect edit/bash events for session summary
# Runs as PostToolUse hook for Write/Edit/MultiEdit/Bash (async)

set -uo pipefail

VAULT="$HOME/Developer/obsidian"
[[ -d "$VAULT" ]] || exit 0

input=$(cat)

state_dir="$HOME/.claude/state/obsidian"
state_file="$state_dir/current-session.jsonl"
mkdir -p "$state_dir" 2>/dev/null || true

# Determine tool type
tool=$(printf '%s' "$input" | jq -r '.tool // empty')

case "$tool" in
  Write|Edit|MultiEdit)
    file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
    if [[ -n "$file_path" ]]; then
      printf '{"type":"edit","file":"%s","ts":"%s"}\n' "$file_path" "$(date +%H:%M:%S)" >> "$state_file" 2>/dev/null || true
    fi
    ;;
  Bash)
    cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' | head -c 200)
    if [[ -n "$cmd" ]]; then
      # Redact secrets before storing
      cmd=$(printf '%s' "$cmd" | sed -E \
        -e 's/(--token[= ]?)[^ ]*/\1[REDACTED]/g' \
        -e 's/(--password[= ]?)[^ ]*/\1[REDACTED]/g' \
        -e 's/(--body[= ]?)[^ ]*/\1[REDACTED]/g' \
        -e 's/(PASSWORD|TOKEN|SECRET|API_KEY)=[^ ]*/\1=[REDACTED]/g' \
      )
      # Escape for JSON
      cmd=$(printf '%s' "$cmd" | sed 's/"/\\"/g' | tr '\n' ' ')
      printf '{"type":"bash","cmd":"%s","ts":"%s"}\n' "$cmd" "$(date +%H:%M:%S)" >> "$state_file" 2>/dev/null || true
    fi
    ;;
esac

# Pass through
printf '%s\n' "$input"
exit 0
