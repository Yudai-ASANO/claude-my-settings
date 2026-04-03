# あなたは bugfix ワークフローのオーケストレータです。以下のバグを Phase 0 から Phase 3 まで順番に修正してください。

> Skill ツールで `orchestration-patterns` を参照し、ハンドオフ形式・レポート形式・重要なルールに従うこと。

## バグ

$ARGUMENTS

---

## Phase 0: 調査（researcher エージェント）

Agent ツールで `researcher` エージェントを起動する:

```markdown
## HANDOFF: orchestrator → researcher

### タスク: バグ調査 — $ARGUMENTS

### 指示: 以下の観点で調査してください:

1. バグの再現条件と関連コード
2. 類似バグの事例（WebSearch/WebFetch で外部検索）
3. エラーログ・スタックトレースの分析
4. 影響範囲の特定
```

**ゲート**: Research Report に調査結果が1項目以上あること。なければ停止してユーザーに報告。

---

## Phase 1: デバッグ分析

Skill ツールで `superpowers:systematic-debugging` を起動する。

入力として以下を渡す:

- バグの説明: $ARGUMENTS
- Research Report: [Phase 0 の出力要約]

systematic-debugging の手順に従い、根本原因を特定する。

**フォールバック**: superpowers プラグインが利用不可の場合、Claude 自身で体系的デバッグを実施する。

---

## Phase 2: 修正実装（generator エージェント）

Agent ツールで `generator` エージェントを起動する:

```markdown
## HANDOFF: orchestrator → generator

### タスク: バグ修正 — $ARGUMENTS

### デバッグ分析: [Phase 1 の根本原因と修正方向]

### 指示:

1. まずバグを再現するテストを書く（RED）
2. テストを通す最小限の修正を実装する（GREEN）
3. コード品質を改善する（REFACTOR）
4. 既存テスト + 新規テストが全て通ることを確認する
```

---

## Phase 3: コードレビュー

`/codex:review` コマンドを実行し、修正のコードレビューを実施する。

---

## 最終レポート

`orchestration-patterns` Skill の最終レポート形式を参考に、以下のフォーマットで出力する:

```markdown
ORCHESTRATION REPORT
Workflow: bugfix | Task: $ARGUMENTS
RESEARCH: [Phase 0 要約]
DEBUG: [Phase 1 根本原因]
FIX: [Phase 2 変更サマリ]
CODE REVIEW: [Phase 3 codex:review 要約]
FILES CHANGED: [変更ファイル一覧]
RECOMMENDATION: SHIP / NEEDS WORK / BLOCKED
```
