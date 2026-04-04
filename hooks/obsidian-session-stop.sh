#!/usr/bin/env bash
# Obsidian Session Stop — Auto-log session summary to Obsidian vault
# Runs as Stop hook (async, non-blocking)
# Writes to AI/Sessions/<project>/ and appends to AI/Daily/<date>.md

set -uo pipefail

VAULT="$HOME/Developer/obsidian"

# Bail if vault doesn't exist
[[ -d "$VAULT" ]] || exit 0

# Consume stdin (required by hook protocol)
cat > /dev/null

# Determine project name from CLAUDE_PROJECT_DIR or fallback
if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
  project_name=$(basename "$CLAUDE_PROJECT_DIR")
else
  project_name="unknown"
fi

# Sanitize project name (remove special chars)
project_name=$(printf '%s' "$project_name" | tr -cd '[:alnum:]._-')
[[ -z "$project_name" ]] && project_name="unknown"

# Timestamps
date_str=$(date +%Y-%m-%d)
time_str=$(date +%H%M%S)
iso_time=$(date +%Y-%m-%dT%H:%M:%S%z)

# Session file path
session_dir="$VAULT/AI/Sessions/$project_name"
session_file="$session_dir/${date_str}-${time_str}.md"

# Ensure directories exist — fail if vault is unwritable
if ! mkdir -p "$session_dir" 2>/dev/null || ! mkdir -p "$VAULT/AI/Daily" 2>/dev/null; then
  echo "obsidian-session-stop: cannot create directories in vault" >&2
  exit 1
fi

# Find per-session state file (scoped by CLAUDE_SESSION_ID)
session_id="${CLAUDE_SESSION_ID:-$$}"
state_dir="$HOME/.claude/state/obsidian"
state_file="$state_dir/session-${session_id}.jsonl"

edited_files=""
if [[ -f "$state_file" ]]; then
  edited_files=$(jq -r 'select(.type == "edit") | .file' "$state_file" 2>/dev/null | sort -u | head -20) || true
fi

# Build session note into a temp file, then atomic rename
tmp_file=$(mktemp "${session_dir}/.tmp-session-XXXXXX") || {
  echo "obsidian-session-stop: cannot create temp file" >&2
  exit 1
}

cat > "$tmp_file" <<FRONTMATTER
---
date: $date_str
time: $(date +%H:%M)
project: $project_name
tags: [session, $project_name]
---

# Session: $project_name — $date_str $(date +%H:%M)

## Summary
<!-- Auto-generated session log. Edit to add context. -->
Session in \`$project_name\` ended at $iso_time.

FRONTMATTER

# Add edited files section if available
if [[ -n "$edited_files" ]]; then
  {
    echo "## Changes"
    echo "$edited_files" | while IFS= read -r f; do
      [[ -n "$f" ]] && echo "- \`$f\`"
    done
    echo ""
  } >> "$tmp_file"
fi

cat >> "$tmp_file" <<'EOF'
## Next Actions
- [ ]

## Notes

EOF

# Atomic rename — only persist if write succeeded
if ! mv "$tmp_file" "$session_file" 2>/dev/null; then
  echo "obsidian-session-stop: failed to write session note" >&2
  rm -f "$tmp_file" 2>/dev/null || true
  exit 1
fi

# Append to Daily Note
daily_file="$VAULT/AI/Daily/${date_str}.md"

if [[ ! -f "$daily_file" ]]; then
  cat > "$daily_file" <<DAILY
---
date: $date_str
tags: [daily]
---

# $date_str

## Sessions

DAILY
fi

# Append session link under the project heading
if ! grep -q "^### $project_name" "$daily_file" 2>/dev/null; then
  printf '\n### %s\n' "$project_name" >> "$daily_file"
fi
printf -- '- [[AI/Sessions/%s/%s-%s|%s %s]]\n' \
  "$project_name" "$date_str" "$time_str" \
  "$project_name" "$(date +%H:%M)" >> "$daily_file"

# Only delete state file after both writes succeeded
rm -f "$state_file" 2>/dev/null || true

# Clean up stale state files older than 1 day (orphaned sessions)
find "$state_dir" -name 'session-*.jsonl' -mtime +1 -delete 2>/dev/null || true

exit 0
