# Codex Plugin 委譲ルール

> 以下のルールは `codex-plugin-cc` がインストール・有効化済みの場合にのみ適用する。
> 単純なタスク（1ファイル・数行の修正、設定変更、ドキュメント編集等）は Claude が直接実行してよい。

### アーキテクチャ

```bash
ユーザー → Claude Code（司令塔・設計・統合）
  ↓
  /codex:review, /codex:rescue → Codex Plugin（レビュー・実装・調査）
  ↓
  Claude Code（検証・統合・コミット判断）
```

### コマンドパターン

| 目的             | コマンド                    | 説明                                       |
| ---------------- | --------------------------- | ------------------------------------------ |
| コードレビュー   | `/codex:review`             | 未コミット変更またはブランチ差分のレビュー |
| 設計批評レビュー | `/codex:adversarial-review` | トレードオフ・障害モードへの挑戦           |
| タスク委譲       | `/codex:rescue`             | バグ調査、実装、リサーチの委譲             |
| ジョブ状態確認   | `/codex:status`             | 実行中/完了済みジョブの一覧                |
| 結果取得         | `/codex:result`             | 完了ジョブの出力取得                       |
| ジョブキャンセル | `/codex:cancel`             | 実行中ジョブのキャンセル                   |
| セットアップ確認 | `/codex:setup`              | インストール・認証状態の確認               |

### 委譲の判断基準

#### Codex Plugin に委譲する条件（以下のいずれかを満たす場合）

- コードレビュー → `/codex:review` または `/codex:adversarial-review`
- 新規コード生成が20行以上 → `/codex:rescue`
- 複数ファイルにまたがる変更 → `/codex:rescue`
- バグの根本原因分析 → `/codex:rescue`
- セキュリティ脆弱性スキャン → `/codex:adversarial-review`

#### Claude が直接実行する条件

- 1ファイル・数行の修正
- 設定ファイルの編集（YAML, JSON, TOML 等）
- ドキュメント・README の作成・更新
- git 操作（コミット、ブランチ、マージ）
- ユーザーへの説明・質疑応答

### 委譲ルール

#### 1. レビューは Codex Plugin に任せる

コード変更後のレビューは `/codex:review` で実施する。Claude はレビュー結果を受けて最終判断する。
設計判断の妥当性を確認したい場合は `/codex:adversarial-review` を使用する。

#### 2. バックグラウンドジョブの活用

`/codex:rescue` で委譲したタスクはバックグラウンドで実行される。
`/codex:status` で進捗確認、`/codex:result` で結果取得する。

#### 3. Claude はパススルーしない

Codex の出力をそのままユーザーに見せない。必ず検証・統合した上で報告する。

### レビューゲート

`/codex:setup --enable-review-gate` で有効化すると、Claude の Stop 時に自動的に
Codex レビューが実行される。問題が見つかった場合はセッションがブロックされる。

### セキュリティに関する注意

- API キーや秘密情報を Codex へのプロンプトに含めない
- Codex が生成したコードのセキュリティレビューは必ず実施する
