# Claude Code Harness

Claude Code の設定・エージェント・フック・コマンドを一元管理するリポジトリです。
`scripts/deploy.sh` で `~/.claude/` 配下に展開することで、全プロジェクトに共通の
開発ワークフロー（調査 → 計画 → 実装 → QA → レビュー）を適用できます。

---

## ディレクトリ構成

```
my-settings/
├── CLAUDE.md              # Claude Code のグローバル設定（Codex Plugin / Gemini CLI 運用ルール）
├── AGENTS.md              # エージェント一覧と起動条件の定義
├── settings.json          # パーミッション・フック・プラグイン設定
├── agents/                # サブエージェント定義
│   ├── researcher.md
│   ├── planner.md
│   ├── plan-reviewer.md
│   ├── generator.md
│   ├── qa-reviewer.md
│   ├── security-reviewer.md
│   ├── architect.md
│   ├── tdd-guide.md
│   └── build-error-resolver.md
├── commands/              # スラッシュコマンド定義
│   ├── feature.md
│   ├── bugfix.md
│   ├── refactor.md
│   ├── research.md
│   ├── plan.md
│   ├── review.md
│   ├── verify.md
│   ├── tdd.md
│   ├── learn.md
│   └── handover.md
├── hooks/                 # ライフサイクルフック
│   ├── suggest-compact.sh
│   ├── pre-commit-gate.sh
│   ├── git-push-safety.sh
│   ├── config-protection.sh
│   ├── desktop-notify.sh
│   ├── check-doc-size.sh
│   └── statusline.py
├── rules/                 # コーディング規約・ワークフロールール
│   ├── global.md
│   ├── orchestrate.md
│   ├── coding-style.md
│   ├── anti-patterns.md
│   ├── testing.md
│   ├── security.md
│   └── performance.md
└── scripts/
    └── deploy.sh          # デプロイスクリプト
```

---

## 前提条件

| 依存 | 必須 / 任意 | 用途 |
|------|------------|------|
| bash | 必須 | フック・デプロイスクリプトの実行 |
| Claude Code | 必須 | エージェント・コマンド・フックの実行環境 |
| [gemini CLI](https://github.com/google-gemini/gemini-cli) | 任意 | researcher エージェントが Web 検索・外部調査に使用 |
| [codex-plugin-cc](https://github.com/openai/codex-plugin-cc) | 任意 | コードレビュー・設計批評・タスク委譲に使用 |
| [jq](https://jqlang.github.io/jq/) | 任意 | pre-commit-gate フックが package.json を解析するために使用 |
| osascript | 任意 (macOS) | desktop-notify フックがデスクトップ通知を送信するために使用 |

gemini CLI と codex-plugin-cc が未インストールの場合、対応する機能はスキップまたは
Claude 自身が代替処理を行います。

---

## インストール（デプロイ）

`scripts/deploy.sh` がリポジトリの内容を `~/.claude/` へコピーします。
既存ファイルは自動バックアップされます。

### 通常デプロイ

```bash
bash scripts/deploy.sh
```

変更のあったファイルのみコピーし、既存ファイルはタイムスタンプ付きのバックアップ先
（`~/.claude/.backup/YYYYMMDD-HHMMSS/`）に退避してから上書きします。

### ドライラン（変更内容の確認のみ）

```bash
bash scripts/deploy.sh --dry-run
```

実際のコピーは行わず、コピーされる予定のファイルを `[would copy]` として表示します。
デプロイ前の影響範囲確認に使用してください。

```
=== Claude Code Harness Dry Run ===
Core:
  [ok] settings.json
  [would copy] CLAUDE.md
Agents:
  [would copy] researcher.md
...
Done.
```

### ステータス確認

```bash
bash scripts/deploy.sh --status
```

`~/.claude/` 上の各ファイルがリポジトリと一致しているか (`[ok]`)、差分があるか
(`[modified]`)、存在しないか (`[missing]`) を表示します。実際のコピーは行いません。

```
=== Claude Code Harness Status ===
Core:
  [ok] settings.json
  [modified] CLAUDE.md
Hooks:
  [missing] desktop-notify.sh
...
Done.
```

---

## コマンドリファレンス

Claude Code のチャット画面で `/` に続けてコマンド名を入力して使用します。

### ワークフローコマンド（全フェーズ自動実行）

#### `/feature <説明>`

新機能・新エンドポイント・新コンポーネントの実装に使用します。
Phase 0（調査）から Phase 7（最終レポート）まで全フェーズを自動実行します。

```
/feature ユーザープロフィール画像のアップロード機能を追加する
```

実行フロー:
1. researcher が外部調査 + コードベース分析
2. planner が Sprint Contract（受入基準 + 並列タスク）を生成
3. plan-reviewer が Sprint Contract を検証（APPROVE まで最大2回修正）
4. generator が TDD で実装（独立タスクは並列実行）
5. オーケストレータが検証コマンドを実行してエビデンス収集
6. qa-reviewer がエビデンスベースで PASS/FAIL を判定（最大3ラウンド）
7. codex:review + security-reviewer が並列レビュー
8. 最終レポート（SHIP / NEEDS WORK / BLOCKED）を出力

#### `/bugfix <説明>`

バグ修正・エラー調査に使用します。Phase 0〜3 の 4 フェーズを実行します。

```
/bugfix ログイン後にリダイレクトが無限ループする
```

実行フロー:
1. researcher がバグ再現条件・影響範囲を調査
2. `superpowers:systematic-debugging` スキルで根本原因を特定
3. generator がバグ再現テストを先に書いてから修正を実装（TDD）
4. codex:review でコードレビュー

#### `/refactor <説明>`

リファクタリング・構造変更に使用します。Phase 0〜3 の 4 フェーズを実行します。

```
/refactor UserService クラスを Repository パターンに分割する
```

実行フロー:
1. researcher が対象コードの現状構造・依存関係・影響範囲を調査
2. `feature-dev:code-architect` スキルでリファクタリング設計を策定
3. generator が既存テストを維持しながら実装（振る舞い不変）
4. codex:review でコードレビュー

### 個別フェーズコマンド（単独実行）

#### `/research <対象>`

実装前に技術調査や情報収集をしたいときに使います。gemini CLI で外部調査 + Grep/Glob でコードベース分析を行い、Research Report を生成します。後続の `/plan` に渡す資料として使用できます。

```
/research React Server Components のキャッシュ戦略
```

#### `/plan <説明>`

実装の計画を立てたいときに使います。コンテキストに Research Report があれば活用し、Sprint Contract（受入基準 + 並列タスク分割）を生成します。

```
/plan 決済フローにリトライ機能を追加する
```

#### `/review`

コードの品質やセキュリティを確認したいときに使います。未コミット変更またはブランチ差分に対して codex:review と security-reviewer を並列実行し、統合レポートを出力します。

```
/review
```

#### `/verify [対象]`

コミット前やデプロイ前に、プロジェクトの各種チェックをまとめて実行したいときに使います。`package.json` / `Cargo.toml` / `Makefile` 等からビルド・型チェック・リント・テスト・セキュリティ監査のコマンドを自動検出し、順次実行します。

```
/verify
```

#### `/tdd <対象>`

テスト駆動開発で機能を実装したいときに使います。tdd-guide エージェントを起動し、RED → GREEN → REFACTOR サイクルを厳守しながらテスト設計・実装・品質レビューまで一貫して進めます。

```
/tdd パスワードバリデーション関数
```

#### `/learn [対象]`

セッション中に発見した有用なパターンや知見を記録したいときに使います。コードパターン・デバッグ手法・ワークフローの知見を評価し、再利用価値の高いものをメモリまたは CLAUDE.md に保存します。

```
/learn
```

#### `/handover [メモ]`

作業を中断して別のセッションで引き継ぎたいときに使います。現在のブランチ状態・完了/未完了タスク・未コミット変更・次にやるべきことをまとめた引き継ぎ文書（`HANDOVER.md`）を自動生成します。

```
/handover 認証機能の実装途中、テスト未完了
```

---

## ワークフロー概要

### feature（Phase 0-7）

```
Phase 0: researcher ──→ Research Report
Phase 1: planner ──────→ Sprint Contract
Phase 2: plan-reviewer → APPROVE / REVISE（最大2回ループ）
Phase 3: generator×N ──→ 実装（独立タスクは worktree 分離で並列）
Phase 4: エビデンス収集（オーケストレータが検証コマンドを実行）
Phase 5: qa-reviewer ──→ PASS / FAIL（最大3ラウンドループ）
Phase 6: codex:review + security-reviewer（並列）
Phase 7: 最終レポート（SHIP / NEEDS WORK / BLOCKED）
```

### bugfix（Phase 0-3）

```
Phase 0: researcher ───────────────────→ Research Report
Phase 1: superpowers:systematic-debugging → 根本原因特定
Phase 2: generator ────────────────────→ バグ再現テスト + 修正実装
Phase 3: codex:review ─────────────────→ コードレビュー
```

### refactor（Phase 0-3）

```
Phase 0: researcher ──────────────→ Research Report
Phase 1: feature-dev:code-architect → リファクタリング設計
Phase 2: generator ───────────────→ 振る舞い不変で実装
Phase 3: codex:review ────────────→ コードレビュー
```

### 品質ゲート

| フェーズ間 | 条件 | 失敗時 |
|-----------|------|--------|
| Phase 0 → 1 | Research Report に1項目以上 | ブロック・ユーザー報告 |
| Phase 1 → 2 | Sprint Contract に受入基準1つ以上 | ブロック |
| Phase 2 → 3 | plan-reviewer = APPROVE | REVISE ループ（最大2回） |
| Phase 4 → 5 | 全基準にコマンド出力あり | 欠落コマンドを再実行 |
| Phase 5 → 6 | qa-reviewer = PASS | 修復ループ（最大3回） |
| Phase 6 → 7 | security-reviewer の CRITICAL 0件 | SHIP 不可・ユーザー報告 |

---

## エージェント一覧

### ワークフローエージェント

| エージェント | 役割 | モデル | permissionMode |
|------------|------|--------|----------------|
| researcher | 外部調査（gemini-cli）+ コードベース分析で Research Report を生成 | sonnet | plan |
| planner | Research Report を入力として Sprint Contract（受入基準 + タスク分割）を生成 | opus | plan |
| plan-reviewer | Sprint Contract の妥当性を検証し APPROVE / REVISE を判定 | sonnet | plan |
| generator | Sprint Contract に従って TDD でコードを実装する | sonnet | （制限なし） |
| qa-reviewer | エビデンス（検証コマンド出力）のみで PASS / FAIL を判定 | sonnet | plan |
| security-reviewer | 変更コードの高リスクパターンをスキャンし PASS / FAIL を判定 | sonnet | plan |

### 専門エージェント

| エージェント | 役割 | モデル | 起動条件 |
|------------|------|--------|---------|
| architect | 設計批評・トレードオフ分析・アーキテクチャレビュー | opus | 手動呼び出し（設計判断の検証時） |
| tdd-guide | TDD サイクル強制・テスト品質レビュー・テスト戦略策定 | opus | `/tdd` コマンドで起動 |
| build-error-resolver | ビルドエラー自動診断・修復提案（型/リンター/ビルドエラー対応） | sonnet | 手動呼び出し（ビルドエラー発生時） |

`permissionMode: plan` のエージェントはファイルの書き込み・編集が禁止されています。
generator のみが実際のコード変更を担当します。

---

## フック一覧

| フック名 | トリガー | 動作 |
|---------|---------|------|
| suggest-compact | Edit / Write ツール使用時（PreToolUse） | ツール呼び出し回数をカウントし、しきい値（デフォルト 50 回）に達したら `/compact` を勧める警告を stderr に出力する |
| pre-commit-gate | `git commit` 実行時（PreToolUse） | package.json / Makefile / Cargo.toml 等からテスト・リントコマンドを自動検出して実行する。`HARNESS_GATE_MODE=strict` の場合は失敗でコミットをブロックする |
| git-push-safety | `git push` 実行時（PreToolUse） | `--force` / `-f` / `--force-with-lease` が main / master / production / release ブランチに対して使われている場合はブロックする |
| config-protection | ESLint / Prettier 等の設定ファイルへの Edit / Write 時（PreToolUse） | `.eslintrc`・`.prettierrc`・`biome.json` 等のリンター設定ファイルへの変更をブロックする（ルールを緩める修正を防止） |
| desktop-notify | Claude Code の応答終了時（Stop） | macOS の osascript で「Task completed」デスクトップ通知を送信する（macOS 以外は何もしない） |
| check-doc-size | CLAUDE.md / AGENTS.md への Write 後（PostToolUse） | ファイル行数を検証し、警告しきい値（CLAUDE.md: 150行 / AGENTS.md: 60行）と上限（CLAUDE.md: 300行 / AGENTS.md: 100行）を超えた場合に警告・エラーを出力する |
| statusline.py | ステータスライン表示（statusLine 設定） | 使用中のモデル名、コンテキスト消費率、レートリミット（5時間/7日）、累計コストをブライユ文字のプログレスバーで常時表示する |

---

## ルール

| ルールファイル | 内容 |
|--------------|------|
| global.md | 全ルールのエントリポイント。ワークフロー判断・Git 規約・基本規律を定義 |
| orchestrate.md | `/feature` / `/bugfix` / `/refactor` の実行チェーン、品質ゲート、エビデンス収集プロトコル、ハンドオフフォーマット |
| coding-style.md | 不変性・ファイル/関数サイズ・命名規則・エラーハンドリング・構造の推奨パターン |
| anti-patterns.md | Silent catch・Any 型濫用・マジックナンバー・深いネスト等の禁止パターンと検出時の対応 |
| testing.md | TDD サイクル（RED → GREEN → REFACTOR）、カバレッジ基準（80%以上）、テスト設計・品質の方針 |
| security.md | 秘密情報の保護・プロンプトインジェクション防御・入力サニタイズ・依存関係管理・認証/認可 |
| performance.md | 計測優先の最適化方針、N+1 クエリ回避、DB/フロントエンドのパフォーマンス指針 |

---

## 環境変数

| 変数名 | デフォルト | 説明 |
|--------|----------|------|
| `HARNESS_GATE_MODE` | （未設定） | `strict` にすると `pre-commit-gate` フックがテスト/リント失敗時にコミットをブロックする。未設定（advisory モード）の場合は警告のみ出してコミットを続行する |
| `COMPACT_THRESHOLD` | `50` | `suggest-compact` フックがコンパクトを提案するツール呼び出し回数のしきい値。セッションが長くなるほど小さい値にすると早めに提案される |

環境変数はシェルのプロファイルまたはプロジェクト固有の `.env.local` で設定します。
なお `.env` ファイルは `settings.json` のパーミッション設定により Claude Code からは読み込み禁止です。

### 設定例（~/.zshrc）

```bash
# pre-commit-gate でテスト失敗時にコミットをブロックする
export HARNESS_GATE_MODE=strict

# 30 ツール呼び出しごとにコンパクトを提案する
export COMPACT_THRESHOLD=30
```

---

## カスタマイズ

`settings.json` の主要設定を変更することで動作をカスタマイズできます。

### パーミッション設定

```jsonc
// settings.json
{
  "permissions": {
    "allow": [
      "Bash(git *)",       // git コマンドを許可
      "Bash(jq *)"         // jq を許可（pre-commit-gate が使用）
    ],
    "deny": [
      "Bash(rm -rf *)",    // 再帰削除を禁止
      "Bash(sudo *)",      // sudo を禁止
      "Read(**/.env)"      // .env の読み込みを禁止
    ]
  }
}
```

### フック設定

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        // Edit / Write 時に suggest-compact を実行
        "matcher": "tool == \"Edit\" || tool == \"Write\"",
        "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/suggest-compact.sh" }]
      }
    ],
    "Stop": [
      {
        // 応答終了時にデスクトップ通知（非同期）
        "matcher": "*",
        "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/desktop-notify.sh", "async": true }]
      }
    ]
  }
}
```

### プラグイン設定

```jsonc
{
  "enabledPlugins": {
    "security-guidance@claude-plugins-official": true,
    "commit-commands@claude-plugins-official": true,
    "pr-review-toolkit@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
    "code-review@claude-plugins-official": true,
    "claude-md-management@claude-plugins-official": true,
    "superpowers@claude-plugins-official": true,
    "code-simplifier@claude-plugins-official": true,
    "document-skills@anthropic-agent-skills": true,
    "example-skills@anthropic-agent-skills": true,
    "codex@openai-codex": true
  },
  "enableAllProjectMcpServers": false  // セキュリティのため false を維持
}
```

---

## ライセンス

MIT
