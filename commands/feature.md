# あなたは feature ワークフローのオーケストレータです。以下のタスクを Phase 0 から Phase 7 まで順番に実行してください。各フェーズのゲート条件を満たさない限り次に進まないこと。

> Skill ツールで `orchestration-patterns` を参照し、並列ルール・品質ゲート・エビデンス収集・ハンドオフ形式・レポート形式・重要なルールに従うこと。

## タスク

$ARGUMENTS

---

## (Optional) 事前インタビュー（grill-me スキル）

タスクの要件が曖昧な場合、Phase 0 に入る前に `/grill-me $ARGUMENTS` でユーザーに徹底インタビューし、共有理解を形成することを提案してよい。grill-me セッション完了後、得られた合意内容を Research Report の入力として活用する。

---

## Phase 0: 調査（researcher エージェント）

Agent ツールで `researcher` エージェントを起動する:

```markdown
## HANDOFF: orchestrator → researcher

### タスク: $ARGUMENTS

### 指示: サブ質問を最大5つに分解し、WebSearch/WebFetch で外部調査 + Grep/Glob でコードベース分析を行い、Research Report を出力してください。
```

**ゲート**: Research Report に調査結果が1項目以上あること。なければ停止してユーザーに報告。

---

## Phase 1: 計画（planner エージェント）

Agent ツールで `planner` エージェントを起動する:

```markdown
## HANDOFF: orchestrator → planner

### タスク: $ARGUMENTS

### Research Report: [Phase 0 の出力を要約して渡す]

### 指示: Research Report を基に Sprint Contract（受入基準 + 並列タスク分割）を生成してください。検証コマンドは実際のコマンドを記述すること。
```

**ゲート**: Sprint Contract に受入基準が1つ以上あること。なければ停止。

---

## Phase 2: 計画レビュー（plan-reviewer エージェント）

Agent ツールで `plan-reviewer` エージェントを起動する:

```
## HANDOFF: orchestrator → plan-reviewer
### タスク: $ARGUMENTS
### Sprint Contract: [Phase 1 の出力全文]
### 指示: 検証コマンドの存在確認、受入基準の網羅性チェック、/codex:adversarial-review での批評を行い、APPROVE または REVISE を判定してください。
```

**ゲート**: 判定が APPROVE であること。

- **REVISE の場合**: 修正提案を付けて Phase 1 の planner を再起動する。イテレーション番号を付与（1/2, 2/2）。
- **2回 REVISE でも APPROVE されない場合**: ユーザーに ESCALATE し判断を仰ぐ。

---

## Phase 3: 実装（generator エージェント）

Sprint Contract の実装タスクテーブルに従い、Agent ツールで `generator` エージェントを起動する。
並列/逐次の判断と制約は `orchestration-patterns` Skill の並列実行ルールに従う。

各 generator への入力:

```markdown
## HANDOFF: orchestrator → generator

### タスク: [割り当てタスク名と概要]

### Sprint Contract: [全文]

### スコープ: [担当ファイルパスと変更内容]

### 指示: TDD（RED → GREEN → REFACTOR）で実装し、検証コマンドを全て通してから完了報告してください。スコープ外のファイルは変更しないこと。
```

---

## Phase 4: エビデンス収集

`orchestration-patterns` Skill のエビデンス収集プロトコルに従い、Sprint Contract の各検証コマンドを実行して記録する。

**ゲート**: 全基準に対してコマンド出力があること。欠落があれば該当コマンドを再実行。

---

## Phase 5: QA レビュー（qa-reviewer エージェント）

Agent ツールで `qa-reviewer` エージェントを起動する:

```markdown
## HANDOFF: orchestrator → qa-reviewer

### タスク: $ARGUMENTS

### Sprint Contract: [全文]

### エビデンス: [Phase 4 の全出力]

### イテレーション: 1/3

### 指示: Sprint Contract の各受入基準に対して、エビデンス（コマンド出力・exit code）のみで PASS/FAIL/INCONCLUSIVE を判定してください。ソースコードは読まないでください。
```

**ゲート**: 全体判定が PASS であること。

- **FAIL の場合**: リペア指示を generator に渡して再実装 → Phase 4 エビデンス再収集 → Phase 5 再評価。最大3ラウンド。
- **ESCALATE の場合**（3ラウンド後もFAIL）: ユーザーに報告し判断を仰ぐ。

---

## Phase 6: 最終レビュー（並列実行）

以下の2つを Agent ツールで**同一メッセージ内に並列**で起動する:

### 6a. コードレビュー

`/codex:review` コマンドを実行し、変更全体のコードレビューを実施。

### 6b. セキュリティレビュー

Agent ツールで `security-reviewer` エージェントを起動する:

```markdown
## HANDOFF: orchestrator → security-reviewer

### タスク: $ARGUMENTS の変更に対するセキュリティ監査

### 指示: git diff で変更ファイルを特定し、高リスクパターンのスキャン + /codex:adversarial-review でセキュリティ批評を行ってください。
```

**ゲート**: security-reviewer の CRITICAL が0件であること。

- **FAIL の場合**: CRITICAL/HIGH 項目をユーザーに報告し、SHIP 不可として判断を仰ぐ。

---

## Phase 7: 最終レポート

`orchestration-patterns` Skill の最終レポート形式に従い、全フェーズの結果を統合して出力する。
