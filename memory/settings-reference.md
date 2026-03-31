---
name: settings-reference
description: Claude Code の環境変数、モデル設定、パーミッション、MCP ツールのクイックリファレンス
type: reference
---

# Settings Quick Reference

## モデル設定

| モデル | ID | 用途 |
|-------|-----|------|
| Opus 4.6 | `claude-opus-4-6` | 深い推論、複雑なタスク |
| Sonnet 4.6 | `claude-sonnet-4-6` | メイン開発 |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | 軽量エージェント |
| Sonnet 1M | `claude-sonnet-4-6[1m]` | 拡張コンテキスト |

### Opus 4.6 推論レベル
- High: デフォルト、フル推論
- Medium: バランス型
- Low: 最小推論、高速

## 主要環境変数

| 変数 | 用途 | 例 |
|------|------|-----|
| `ANTHROPIC_MODEL` | モデル上書き | `claude-sonnet-4-6` |
| `CLAUDE_CODE_SUBAGENT_MODEL` | サブエージェントモデル | `claude-haiku-4-5-20251001` |
| `MAX_THINKING_TOKENS` | 推論トークン上限 | `10000` |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | 自動コンパクション閾値 | `50` |
| `BASH_MAX_TIMEOUT_MS` | Bash タイムアウト | `600000` |
| `MCP_TIMEOUT` | MCP タイムアウト（デフォルト10秒） | `30000` |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Auto Memory 無効化 | `1` |

## パーミッションパターン

### Bash コマンド
```json
"permissions": {
  "allow": ["Bash(npm test)", "Bash(git *)"],
  "deny": ["Bash(rm -rf *)"]
}
```

### ファイル操作
```json
"permissions": {
  "allow": ["Read(src/**)", "Edit(src/**)", "Write(src/**)"]
}
```

### MCP ツール
```json
"permissions": {
  "allow": ["mcp__server-name__tool-name"]
}
```

## ブラウザテスト MCP トークン比較

| ツール | トークン消費 | 用途 |
|--------|------------|------|
| Playwright MCP | ~13.7k | テスト自動化（推奨） |
| Claude in Chrome | ~15.4k | 認証付き手動テスト |
| Chrome DevTools | ~19.0k | パフォーマンスデバッグ |

## Hook イベント

主要フック: `PreToolUse`, `PostToolUse`, `InstructionsLoaded`, `SessionStart`, `Stop`

- Exit 0: 続行
- Exit 1: ログ記録
- Exit 2: ブロック（操作拒否）
