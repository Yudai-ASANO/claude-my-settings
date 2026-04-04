#!/usr/bin/env bash
# Bash Audit Log - Records all Bash tool commands with timestamps
# Runs as PostToolUse hook (async, non-blocking)

set -uo pipefail

# Read hook input from stdin (required by Claude Code hook protocol)
input=$(cat)

# Log directory and file (monthly rotation)
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/bash-audit-$(date +%Y-%m).log"

# Ensure log directory exists with restrictive permissions
mkdir -p "$LOG_DIR" 2>/dev/null || true
chmod 700 "$LOG_DIR" 2>/dev/null || true

# Clean up logs older than 90 days
find "$LOG_DIR" -name 'bash-audit-*.log' -mtime +90 -delete 2>/dev/null || true

# Extract command from hook input
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

if [[ -n "$cmd" ]]; then
  # Redact potential credentials from command before logging
  # Covers: --flag value, --flag=value, env VAR=value, URL-embedded creds,
  # positional secrets (e.g. gh secret set NAME --body VALUE, -H 'Auth: Bearer ...')
  redacted=$(printf '%s' "$cmd" | sed -E \
    -e 's/(--token[= ]?)[^ ]*/\1[REDACTED]/g' \
    -e 's/(--password[= ]?)[^ ]*/\1[REDACTED]/g' \
    -e 's/(--secret[= ]?)[^ ]*/\1[REDACTED]/g' \
    -e 's/(--api-key[= ]?)[^ ]*/\1[REDACTED]/g' \
    -e 's/(--auth[= ]?)[^ ]*/\1[REDACTED]/g' \
    -e 's/(--body[= ]?)[^ ]*/\1[REDACTED]/g' \
    -e 's/(--key[= ]?)[^ ]*/\1[REDACTED]/g' \
    -e "s/(-H[= ]?)['\"][^'\"]*[Aa]uth[^'\"]*['\"]/\1'[REDACTED]'/g" \
    -e "s/(-H[= ]?)['\"][^'\"]*[Bb]earer[^'\"]*['\"]/\1'[REDACTED]'/g" \
    -e 's|https://[^@]+@|https://[REDACTED]@|g' \
    -e 's/(PASSWORD|TOKEN|SECRET|API_KEY|APIKEY|BEARER)=[^ ]*/\1=[REDACTED]/g' \
  )
  timestamp=$(date +%Y-%m-%dT%H:%M:%S%z)
  cwd=$(printf '%s' "$input" | jq -r '.cwd // "unknown"')
  printf '[%s] cwd=%s cmd=%s\n' "$timestamp" "$cwd" "$redacted" >> "$LOG_FILE" 2>/dev/null || true
  chmod 600 "$LOG_FILE" 2>/dev/null || true
fi

# Pass through the original input
printf '%s\n' "$input"
exit 0
