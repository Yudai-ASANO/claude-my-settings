# エージェント一覧

## ワークフローエージェント

| エージェント | モデル | 役割 | 起動条件 |
|------------|--------|------|---------|
| researcher | sonnet | 外部調査 + コードベース分析。gemini-cli 委譲で Web 検索 | Phase 0 で自動起動 |
| planner | opus | Research Report から Sprint Contract を生成 | Phase 1 で自動起動 |
| plan-reviewer | sonnet | Sprint Contract の検証。APPROVE/REVISE を判定 | Phase 2 で自動起動 |
| generator | sonnet | Sprint Contract に従い TDD でコードを実装。worktree 分離で並列起動可能 | Phase 3 で自動起動 |
| qa-reviewer | sonnet | エビデンスベースで受入基準の PASS/FAIL を判定。ソースコードは読まない | Phase 5 で自動起動 |
| security-reviewer | sonnet | セキュリティ監査。高リスクパターンのスキャン | Phase 6 で自動起動 |

## 専門エージェント

| エージェント | モデル | 役割 | 起動条件 |
|------------|--------|------|---------|
| architect | opus | 設計批評・トレードオフ分析。アーキテクチャレビュー | 手動呼び出し（設計判断の検証時） |
| tdd-guide | opus | TDD サイクル強制・テスト品質レビュー・テスト戦略策定 | `/tdd` コマンドで起動 |
| build-error-resolver | sonnet | ビルドエラー自動診断・修復提案。型/リンター/ビルドエラー対応 | 手動呼び出し（ビルドエラー発生時） |
