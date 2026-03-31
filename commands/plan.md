あなたは計画フェーズのオーケストレータです。planner エージェントを起動して Sprint Contract を生成してください。

## タスク

$ARGUMENTS

## 実行手順

### Step 1: 事前情報の確認

現在の会話コンテキストに Research Report（`/research` の出力）があるか確認する。
- **ある場合**: Research Report を planner への入力に含める
- **ない場合**: planner 自身がコードベース分析を行う旨を伝える

### Step 2: planner エージェントの起動

Agent ツールで `planner` エージェントを起動する。以下のプロンプトを渡すこと:

```
## HANDOFF: orchestrator → planner
### タスク: $ARGUMENTS
### Research Report: [あれば全文、なければ「Research Report なし。コードベース分析から開始してください。」]
### 指示:
1. Research Report を読み込む（あれば）
2. テストランナー・リンター・ビルドコマンド・型チェッカーを自動検出する
3. 並列可能な実装タスクに分割する
4. Sprint Contract フォーマットで出力する（検証コマンドは実際のコマンドを記述、プレースホルダ禁止）
```

### Step 3: Sprint Contract の検証

planner の出力を受け取り、以下を確認:
- 受入基準が1つ以上あるか（品質ゲート）
- 各検証コマンドが具体的か（プレースホルダでないか）
- 実装タスクの依存関係が整合しているか

### Step 4: 結果の報告

Sprint Contract をユーザーに提示する。以下も併せて報告:
- 受入基準の数と検証コマンドの一覧
- 実装タスクの分割と依存関係
- 次のステップの提案（レビュー後に実装開始等）

## 注意事項

- Sprint Contract なしの出力は許可しない。planner が Sprint Contract を出さなかった場合は再起動する
- このコマンドは Phase 1 の単独実行。`/feature` ワークフロー内でも同等の処理が行われる
