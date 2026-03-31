---
name: architecture
description: Claude Code ハーネスの Command → Agent → Skills アーキテクチャと RPI ワークフローの設計知見
type: reference
---

# Architecture Knowledge

## Command → Agent → Skills 3層アーキテクチャ

```
Commands (エントリポイント)
  → Agents (ワークフローオーケストレーション)
    → Skills (ドメイン知識の Progressive Disclosure)
```

### 各層の責務

| 層 | 責務 | ファイル位置 | ロードタイミング |
|---|------|-------------|----------------|
| Commands | ユーザー操作のエントリポイント | `.claude/commands/*.md` | `/command` 実行時 |
| Agents | マルチステップワークフロー制御 | `.claude/agents/*.md` (または agents/*.md) | Agent ツールで起動時 |
| Skills | ドメイン固有知識の注入 | `.claude/skills/*/SKILL.md` | 呼び出し時 or 自動判定 |

### Progressive Disclosure

- Skills の description のみ自動ロード（全文はロードしない）
- 実際の skill 内容は呼び出し時にオンデマンドロード
- 不要なコンテキスト消費を防ぐ設計

## RPI ワークフロー

Research → Plan → Implement の3フェーズ構造:

1. **Research**: 実現可能性分析、GO/NO-GO 判定
2. **Plan**: Sprint Contract 生成、受入基準定義
3. **Implement**: フェーズ別実行、検証チェックポイント

**Why:** 事前調査と計画なしの実装は手戻りが大きい。特に複数ファイル変更やアーキテクチャ判断を伴うタスクで効果的。

**How to apply:** `/feature`, `/bugfix`, `/refactor` コマンドで自動実行される。単純タスクは直接実行でよい。

## サブエージェント制約

- サブエージェントは他のサブエージェントを bash 経由で起動できない
- Task ツールで明示的パラメータ指定して起動する
- サブエージェントの作業はコンテキストの 50% 以内に収める
- worktree 分離で並列実行可能

## コンテキストウィンドウ構造

```
[System Prompt]
  ↓
[CLAUDE.md files (ancestor → project → user)]
  ↓
[Auto Memory (MEMORY.md 先頭200行)]
  ↓
[Rules (.claude/rules/*.md)]
  ↓
[Conversation]
```

CLAUDE.md は全文ロード、MEMORY.md は先頭200行/25KB制限。
