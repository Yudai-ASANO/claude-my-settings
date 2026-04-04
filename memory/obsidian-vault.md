---
name: Obsidian Vault 設定
description: ユーザーの Obsidian vault パスと運用方針。ドキュメント保管に ~/Developer/obsidian を使用。
type: reference
---

Obsidian vault: `~/Developer/obsidian`

ユーザーはこのディレクトリにドキュメントを蓄積していく方針。
obsidian-skills（obsidian-markdown, obsidian-bases, json-canvas, obsidian-cli, defuddle）を
Claude Code のスキルとして導入済み（2026-04-04）。

Obsidian CLI: `/opt/homebrew/bin/obsidian`（インストール済み、2026-04-04 確認）
CLI 使用には Obsidian アプリで vault を開いている必要あり。

**How to apply:** Obsidian 関連のファイル操作時はこの vault パスを使用する。
Obsidian Flavored Markdown 構文（wikilinks, callouts, embeds, properties）で記述する。
CLI が使える場合は `obsidian` コマンド経由で操作（検索、タスク管理、デイリーノート等）。
