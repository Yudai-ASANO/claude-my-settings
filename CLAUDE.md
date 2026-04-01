# グローバル設定

## 基本方針
- Conventional Commits 形式でコミットする（feat: / fix: / refactor: / test: / docs: / chore:）
- 長いセッションでは `/clear` を活用してコンテキストをリフレッシュする

## Codex Plugin 運用

> codex-plugin-cc がインストール済みの場合に適用。コードレビューは /codex:review、20行以上のコード生成は /codex:rescue に委譲する。

## Gemini CLI サブエージェント運用

> Gemini CLI は外部情報取得専用。Web 検索・ドキュメント参照・事実確認に使用し、出力は必ず検証する。
