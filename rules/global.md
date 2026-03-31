# Global Rules

## Workflow

機能実装・バグ修正・リファクタリングは `rules/orchestrate.md` のワークフローに従い自動実行する。
1ファイル修正、設定編集、ドキュメント、git 操作、QA は直接実行してよい。

## 詳細ルール参照

- コーディング規約 → `rules/coding-style.md`
- テスト方針 → `rules/testing.md`
- セキュリティ → `rules/security.md`
- 禁止パターン → `rules/anti-patterns.md`
- パフォーマンス → `rules/performance.md`

## Git

Conventional Commits: `feat:` / `fix:` / `refactor:` / `test:` / `docs:` / `chore:`

## Discipline

- API・メソッドは使う前に存在を確認する（import パスを推測しない）
- 要求されたことだけ実装する。勝手に追加しない
- テストが全て通るまで「完了」と言わない
- 同じアプローチを3回試して失敗したら止まって報告する
- 完了前に要件を再確認し、verifier/test/lint の実行結果を示す
