---
name: orchestration-patterns
description: /feature, /bugfix, /refactor ワークフロー実行時の共通パターン集。並列制御、品質ゲート、エビデンス収集、ハンドオフ形式、レポート形式を定義する。
---

# Orchestration Patterns

ワークフローコマンド（/feature, /bugfix, /refactor）の実行時に参照する共通パターン集。

## ワークフローチェーン

### feature

```
(Optional) grill-me: 要件が曖昧な場合、ユーザーに徹底インタビューして共有理解を形成
Phase 0: researcher（WebSearch/WebFetch で Web 検索 + コード分析）
Phase 1: planner（Research Report → Sprint Contract 生成）
Phase 2: plan-reviewer（Sprint Contract 検証 → codex:adversarial-review）
  → REVISE: planner に修正指示（最大2回）
Phase 3: generator × N（並列実装、worktree 分離）
Phase 4: エビデンス収集（オーケストレータが検証コマンド実行）
Phase 5: qa-reviewer（Sprint Contract 対エビデンスで判定）
  → FAIL: リペア → generator → エビデンス → qa-reviewer（最大3回）
  → ESCALATE: ユーザーに報告
Phase 6: /codex:review + security-reviewer（並列）
Phase 7: 最終レポート
```

### bugfix

```
Phase 0: researcher
Phase 1: [superpowers:systematic-debugging]
Phase 2: generator
Phase 3: /codex:review
```

### refactor

```
Phase 0: researcher
Phase 1: [feature-dev:code-architect]
Phase 2: generator
Phase 3: /codex:review
```

## 並列実行ルール

以下のルールは Phase 3（generator 並列起動）と Phase 6（レビュー並列実行）に適用する。

1. **worktree 分離**: 独立タスクは `isolation: worktree` で git worktree を分離して並列起動する。依存タスクは逐次起動する
2. **Task ツール必須**: サブエージェントの起動は Agent/Task ツール経由で行う。bash 経由のサブエージェント起動は動作しない
3. **スコープ厳守**: 各 generator は Sprint Contract で割り当てられたスコープ外のファイルを変更しない。ファイルパスの重複なき分割が前提
4. **コンテキスト制約**: サブエージェント1インスタンスあたりコンテキストの 50% 以内で作業を完了させる
5. **MEMORY.md 共有**: MEMORY.md は同一 git リポジトリ内の全 worktree で共有される。知識ベースは全インスタンスで参照可能
6. **MEMORY.md 書き込み競合回避**: 並列実行中に MEMORY.md を書き込むタスクがある場合、そのタスクは並列ではなく逐次に配置する

## エビデンス収集プロトコル

オーケストレータ（Claude メインスレッド）が Sprint Contract の各検証コマンドを実行し、以下を記録:

- exit code
- stdout（末尾30行）
- stderr（非空の場合、末尾10行）

エビデンスは加工せず qa-reviewer に渡す。

## ハンドオフフォーマット

```markdown
## HANDOFF: [source] → [target]

### タスク: [説明]

### Research Report: [researcher 出力]

### Sprint Contract: [全文]

### 前フェーズ結果: [要約]

### エビデンス: [検証出力]

### イテレーション: N/max
```

## 最終レポート

```
ORCHESTRATION REPORT
Workflow: [type] | Task: [description]
RESEARCH: [researcher 調査サマリ]
PLAN REVIEW: [plan-reviewer 判定]
SPRINT CONTRACT: [qa-reviewer 判定テーブル]
CODE REVIEW: [codex:review 要約]
SECURITY: [security-reviewer 要約]
FILES CHANGED: [一覧]
RECOMMENDATION: SHIP / NEEDS WORK / BLOCKED
```

## 重要なルール

1. **ゲート厳守**: 各ゲート条件を満たさない限り次のフェーズに進まない
2. **ループ上限**: Plan REVISE 最大2回、QA FAIL 最大3回。超過したら ESCALATE
3. **パススルー禁止**: エージェント/codex の生出力をそのまま使わない。検証・統合してからハンドオフ
4. **コンテキスト節約**: 各ハンドオフ時に前フェーズの出力を要約する（全文持ち回りはしない。ただし Sprint Contract は全文を維持）
5. **フォールバック**: codex plugin が利用不可の場合、その旨をユーザーに報告し代替手段を提案する
