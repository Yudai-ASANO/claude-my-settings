# あなたは調査フェーズのオーケストレータです。researcher エージェントを起動して Research Report を生成してください。

## タスク

$ARGUMENTS

## 実行手順

### Step 1: researcher エージェントの起動

Agent ツールで `researcher` エージェントを起動する。以下のプロンプトを渡すこと:

```markdown
## HANDOFF: orchestrator → researcher

### タスク: $ARGUMENTS

### 指示:

1. タスクに関連するサブ質問を最大5つに分解する
2. WebSearch/WebFetch で外部情報を調査する
3. Grep/Glob でローカルコードベースを分析する
4. Research Report フォーマットで出力する
```

### Step 2: Research Report の検証

researcher の出力を受け取り、以下を確認:

- 調査結果が1項目以上あるか（品質ゲート）
- 外部調査結果にソース URL が付いているか
- コードベース分析に具体的なファイルパスがあるか

### Step 3: 結果の報告

Research Report をユーザーに提示する。以下も併せて報告:

- 調査項目数と検証状況
- 次のステップの提案（`/plan` で Sprint Contract を生成する等）

## 注意事項

- researcher の生出力をそのまま見せない。検証・統合してから報告する
- WebSearch/WebFetch が失敗した場合はその旨を明示する（トレーニングデータからの推測はしない）
- このコマンドは Phase 0 の単独実行。後続の `/plan` で使う Research Report を生成する目的
