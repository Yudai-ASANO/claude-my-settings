#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook: 有効機能に応じた必須ツールの存在確認
# Hook プロトコル: stdin/stdout 不使用。stderr に警告出力。exit 0 固定。

SETTINGS_FILE="$HOME/.claude/settings.json"

# 常に必要な基本ツール
REQUIRED_TOOLS=("jq" "python3" "shellcheck")

# settings.json の permissions.allow 配列から有効機能を判定し条件付きツールを追加
if [ -f "$SETTINGS_FILE" ] && command -v jq &>/dev/null; then
  if jq -e '.permissions.allow // [] | any(test("gemini"))' "$SETTINGS_FILE" &>/dev/null; then
    REQUIRED_TOOLS+=("gemini")
  fi
fi

MISSING=()
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    MISSING+=("$tool")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "[SessionStart] WARNING: missing tools: ${MISSING[*]}" >&2
fi

exit 0
