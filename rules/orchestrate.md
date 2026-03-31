# Orchestration Rule

## 実行方法

### ワークフローコマンド（全フェーズ自動実行）

| コマンド | ワークフロー | 用途 |
|---------|-------------|------|
| `/feature <説明>` | feature (Phase 0-7) | 新機能・新エンドポイント・新コンポーネント |
| `/bugfix <説明>` | bugfix (Phase 0-3) | バグ修正・エラー調査 |
| `/refactor <説明>` | refactor (Phase 0-3) | リファクタリング・構造変更 |

### 個別フェーズコマンド（単独実行）

| コマンド | 対応フェーズ | 用途 |
|---------|-------------|------|
| `/research <対象>` | Phase 0 | 独立調査・事前リサーチ |
| `/plan <説明>` | Phase 1 | Sprint Contract 生成 |
| `/review` | Phase 6 | コード + セキュリティレビュー |

上記パターンのタスクを受けた場合、対応するコマンドの実行を提案する。
除外（直接実行）: 1ファイル数行修正、設定編集、ドキュメント、git 操作、QA

## ワークフローチェーン

### feature

```
Phase 0: researcher（gemini-cli 委譲で Web 検索 + コード分析）
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

## 品質ゲート

| ゲート | フェーズ間 | 条件 | 失敗時 |
|-------|----------|------|--------|
| Research 完了 | 0→1 | Research Report に1項目以上 | ブロック |
| Sprint Contract | 1→2 | 受入基準1つ以上 | ブロック |
| Plan APPROVE | 2→3 | plan-reviewer = APPROVE | REVISE ループ（最大2回） |
| エビデンス完備 | 4→5 | 全基準にコマンド出力あり | ブロック |
| QA PASS | 5→6 | qa-reviewer 全体 = PASS | 修復ループ（最大3回） |
| Security PASS | 6→7 | CRITICAL 0件 | SHIP 不可 |

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
