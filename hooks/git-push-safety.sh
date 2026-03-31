#!/usr/bin/env bash
# Git Push Safety — blocks force push to protected branches
set -euo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

if printf '%s' "$cmd" | grep -qE '\s(--force|-f|--force-with-lease)\b'; then
  if printf '%s' "$cmd" | grep -qE '\s(main|master|production|release)\b'; then
    echo "[Hook] BLOCKED: Force push to protected branch." >&2
    exit 1
  fi
  echo "[Hook] WARNING: Force push detected." >&2
fi

printf '%s\n' "$input"
