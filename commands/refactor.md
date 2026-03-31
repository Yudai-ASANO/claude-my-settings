あなたは refactor ワークフローのオーケストレータです。以下のリファクタリングを Phase 0 から Phase 3 まで順番に実行してください。

## リファクタリング

$ARGUMENTS

---

## Phase 0: 調査（researcher エージェント）

Agent ツールで `researcher` エージェントを起動する:

```
## HANDOFF: orchestrator → researcher
### タスク: リファクタリング調査 — $ARGUMENTS
### 指示: 以下の観点で調査してください:
1. 対象コードの現状構造と依存関係
2. 影響範囲（インポート元、呼び出し元）
3. 関連するベストプラクティス（gemini-cli で外部検索）
4. 既存テストのカバレッジ
```

**ゲート**: Research Report に調査結果が1項目以上あること。なければ停止してユーザーに報告。

---

## Phase 1: アーキテクチャ設計

Skill ツールで `feature-dev:code-architect` を起動する。

入力として以下を渡す:
- リファクタリングの説明: $ARGUMENTS
- Research Report: [Phase 0 の出力要約]

code-architect の手順に従い、リファクタリング設計を策定する。

---

## Phase 2: 実装（generator エージェント）

Agent ツールで `generator` エージェントを起動する:

```
## HANDOFF: orchestrator → generator
### タスク: リファクタリング実装 — $ARGUMENTS
### アーキテクチャ設計: [Phase 1 の設計内容]
### 指示:
1. 既存テストが全て通ることを確認する（GREEN ベースライン）
2. 設計に従ってリファクタリングを実施する
3. 各ステップ後にテストが通ることを確認する（振る舞いを変えない）
4. リンター・型チェックも通すこと
```

---

## Phase 3: コードレビュー

`/codex:review` コマンドを実行し、リファクタリングのコードレビューを実施する。

---

## 最終レポート

```
ORCHESTRATION REPORT
Workflow: refactor | Task: $ARGUMENTS
RESEARCH: [Phase 0 要約]
ARCHITECTURE: [Phase 1 設計サマリ]
IMPLEMENTATION: [Phase 2 変更サマリ]
CODE REVIEW: [Phase 3 codex:review 要約]
FILES CHANGED: [変更ファイル一覧]
RECOMMENDATION: SHIP / NEEDS WORK / BLOCKED
```

## 重要なルール

1. **ゲート厳守**: Research Report が空なら Phase 1 に進まない
2. **振る舞い不変**: リファクタリングは機能を変えない。既存テストを壊さないこと
3. **パススルー禁止**: エージェント/codex の生出力を検証・統合してから報告する
4. **フォールバック**: feature-dev プラグインが利用不可の場合、Claude 自身でアーキテクチャ設計を実施する
