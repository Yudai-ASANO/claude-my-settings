---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

この計画・設計のあらゆる側面について、共有理解に到達するまで徹底的にインタビューしてください。
デシジョンツリーの各ブランチを一つずつたどり、決定間の依存関係を解決していくこと。

各質問には、あなたの推奨回答を添えてください。

質問は一度に一つずつ行ってください。

コードベースを調べれば答えられる質問は、質問する代わりにコードベースを探索して確認してください。

## 完了時

すべてのブランチが解決し共有理解に到達したら、以下の形式で **設計サマリー** を出力してください。
このサマリーはコンテキスト圧縮後も `/plan` への入力として残るため、自己完結した内容にすること。

```
## 設計サマリー（grill-me 結果）

### 決定事項
- （確定した設計判断を箇条書き）

### 前提・制約
- （設計の前提条件、技術的制約、スコープ外とした事項）

### 未解決・リスク
- （保留事項、要追加調査、既知のリスク）

### 主要トレードオフ
- （検討した代替案と採用理由）
```

サマリー出力後、次のように提案してください:

> 設計が固まりました。`/plan` で Sprint Contract を生成しますか？
