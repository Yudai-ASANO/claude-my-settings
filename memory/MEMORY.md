# Memory Index

このプロジェクトは Claude Code ハーネス設定管理リポジトリ（agents, commands, rules, hooks, scripts）。
`~/.claude/` にデプロイして全プロジェクトで共有する。

## トピックファイル

| ファイル | 内容 |
|---------|------|
| [architecture.md](architecture.md) | Command → Agent → Skills 3層アーキテクチャ、RPI ワークフロー、コンテキストウィンドウ構造 |
| [best-practices.md](best-practices.md) | 運用ベストプラクティス、コンテキスト管理、コミット規律、アンチパターン |
| [context-engineering.md](context-engineering.md) | CLAUDE.md ロード戦略、rules 活用、Settings 優先チェーン、Auto Memory 仕様 |
| [settings-reference.md](settings-reference.md) | モデル選択、環境変数、パーミッション、MCP ツール、Hook イベント |

## キーポイント（頻繁に参照する知見）

- CLAUDE.md は 150-200行以内に収める。超過でアドヒアランス低下
- MEMORY.md は先頭200行/25KBのみセッション開始時ロード
- トピックファイルはオンデマンド読み込み（起動時ロードなし）
- コンテキスト 50% で手動コンパクション推奨
- サブエージェントは Task ツールで起動（bash 起動不可）
- deploy.sh でリポジトリから `~/.claude/` へデプロイ

## ハーネス構成

```
my-settings/
├── CLAUDE.md        → ~/.claude/CLAUDE.md
├── AGENTS.md        → ~/.claude/AGENTS.md
├── settings.json    → ~/.claude/settings.json
├── agents/*.md      → ~/.claude/agents/
├── commands/*.md    → ~/.claude/commands/
├── rules/*.md       → ~/.claude/rules/
├── hooks/*.sh       → ~/.claude/hooks/
├── memory/*.md      → ~/.claude/projects/<project>/memory/
└── scripts/deploy.sh
```

## ワークフローコマンド

| コマンド | 用途 |
|---------|------|
| `/feature` | 新機能（Phase 0-7 全自動） |
| `/bugfix` | バグ修正（Phase 0-3） |
| `/refactor` | リファクタリング（Phase 0-3） |
| `/research` | 独立調査 |
| `/plan` | Sprint Contract 生成 |
| `/review` | コード + セキュリティレビュー |
| `/learn` | パターン学習・知見記録 |
| `/verify` | build/type/lint/test/audit 検証 |
