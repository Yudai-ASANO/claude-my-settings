# あなたはレビューフェーズのオーケストレータです。コードレビューとセキュリティレビューを並列実行し、統合結果を報告してください。

## 実行手順

### Step 1: レビュー対象の確認

```bash
git status
git diff --stat HEAD
```

未コミット変更またはブランチ差分を確認する。変更がない場合はユーザーに報告して終了。

### Step 2: 並列レビューの実行

以下の2つを**並列**で実行する:

#### 2a. コードレビュー（codex）

`/codex:review` コマンドを実行する。未コミット変更またはブランチ差分のレビューを依頼。

#### 2b. セキュリティレビュー（security-reviewer エージェント）

Agent ツールで `security-reviewer` エージェントを起動する。以下のプロンプトを渡すこと:

```markdown
## HANDOFF: orchestrator → security-reviewer

### タスク: 現在の変更差分に対するセキュリティ監査

### 指示:

1. git diff で変更ファイル一覧を取得
2. 高リスクパターンを Grep でスキャン
3. /codex:adversarial-review にセキュリティ批評を委譲
4. Security Review Report フォーマットで出力
```

### Step 3: 結果の統合

両レビューの結果を受け取り、以下を統合して報告:

```markdown
## Review Report

### コードレビュー（codex）

[codex:review の結果要約]

### セキュリティレビュー

[security-reviewer の結果要約]

- CRITICAL: [件数]
- HIGH: [件数]
- MEDIUM: [件数]
- LOW: [件数]

### 総合判定: PASS / NEEDS WORK

- PASS: コードレビューで重大な問題なし かつ CRITICAL/HIGH 0件
- NEEDS WORK: 上記を満たさない場合（修正必要項目を列挙）
```

## 注意事項

- codex と security-reviewer の生出力をそのまま見せない。検証・統合してから報告する
- CRITICAL/HIGH が見つかった場合は修正方向を提案する
- このコマンドは `/feature` の Phase 6 と同等。独立して実行可能
