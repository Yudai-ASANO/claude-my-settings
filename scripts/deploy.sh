#!/usr/bin/env bash
set -euo pipefail

# Claude Code Harness — Deploy Script
# Copies settings.json, CLAUDE.md, agents/, rules/, hooks/, commands/, skills/, memory/ to ~/.claude/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
BACKUP_DIR="$CLAUDE_DIR/.backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=false
STATUS=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --status)  STATUS=true ;;
    --help|-h) echo "Usage: $0 [--dry-run|--status]"; exit 0 ;;
  esac
done

checksum() { shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'; }

backup_needed=false
ensure_backup() {
  if ! $backup_needed; then mkdir -p "$BACKUP_DIR"; backup_needed=true; fi
}

deploy_file() {
  local src="$1" dst="$2" name
  name="$(basename "$src")"

  if [ -f "$dst" ] && [ "$(checksum "$src")" = "$(checksum "$dst")" ]; then
    echo "  [ok] $name"
    return
  fi

  if $STATUS; then
    [ -f "$dst" ] && echo "  [modified] $name" || echo "  [missing] $name"
    return
  fi

  if $DRY_RUN; then
    echo "  [would copy] $name"
    return
  fi

  if [ -f "$dst" ]; then
    ensure_backup
    cp "$dst" "$BACKUP_DIR/$(echo "$dst" | sed "s|$CLAUDE_DIR/||" | tr '/' '_')"
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  [ -x "$src" ] && chmod +x "$dst"
  echo "  [copied] $name"
}

# --- Deploy ---
echo "=== Claude Code Harness $(if $STATUS; then echo 'Status'; elif $DRY_RUN; then echo 'Dry Run'; else echo 'Deploy'; fi) ==="

echo "Core:"
deploy_file "$PROJECT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
deploy_file "$PROJECT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
deploy_file "$PROJECT_DIR/AGENTS.md" "$CLAUDE_DIR/AGENTS.md"

echo "Agents:"
mkdir -p "$CLAUDE_DIR/agents"
for f in "$PROJECT_DIR"/agents/*.md; do
  [ -f "$f" ] && deploy_file "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

echo "Rules:"
mkdir -p "$CLAUDE_DIR/rules"
for f in "$PROJECT_DIR"/rules/*.md; do
  [ -f "$f" ] && deploy_file "$f" "$CLAUDE_DIR/rules/$(basename "$f")"
done

echo "Hooks:"
mkdir -p "$CLAUDE_DIR/hooks"
for f in "$PROJECT_DIR"/hooks/*.sh "$PROJECT_DIR"/hooks/*.py; do
  [ -f "$f" ] && deploy_file "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
done

echo "Commands:"
mkdir -p "$CLAUDE_DIR/commands"
for f in "$PROJECT_DIR"/commands/*.md; do
  [ -f "$f" ] && deploy_file "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
done

echo "Skills:"
if [ -d "$PROJECT_DIR/skills" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#"$PROJECT_DIR/skills/"}"
    mkdir -p "$CLAUDE_DIR/skills/$(dirname "$rel")"
    deploy_file "$f" "$CLAUDE_DIR/skills/$rel"
  done < <(find "$PROJECT_DIR/skills" -type f -print0)
else
  echo "  [skip] skills/ not found"
fi

echo "Memory:"
# Auto Memory deploys to ~/.claude/projects/<project>/memory/
# Claude Code encodes the project path by replacing / with -
ENCODED_PROJECT="$(echo "$PROJECT_DIR" | tr '/' '-')"
MEMORY_PROJECT_DIR="$CLAUDE_DIR/projects/$ENCODED_PROJECT/"

if [ -d "$MEMORY_PROJECT_DIR" ]; then
  MEMORY_DST="${MEMORY_PROJECT_DIR}memory"
  mkdir -p "$MEMORY_DST"
  for f in "$PROJECT_DIR"/memory/*.md; do
    [ -f "$f" ] && deploy_file "$f" "$MEMORY_DST/$(basename "$f")"
  done
else
  echo "  [skip] project dir not found: $ENCODED_PROJECT (run claude in this repo first)"
fi

echo ""
if $backup_needed; then echo "Backup: $BACKUP_DIR"; fi
echo "Done."
