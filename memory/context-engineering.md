---
name: context-engineering
description: CLAUDE.md のロード戦略、rules の活用法、Progressive Disclosure、設定ファイル階層の詳細
type: reference
---

# Context Engineering

## CLAUDE.md ロード戦略

### ディレクトリウォーク（上方向）
Claude Code は起動時にカレントディレクトリから**上方向**にディレクトリツリーを歩き、全ての CLAUDE.md をロードする。

```
/                         ← ロード（存在すれば）
├── Users/
│   └── y-asano/
│       └── project/
│           ├── CLAUDE.md  ← ロード（カレント）
│           └── sub/
│               └── CLAUDE.md  ← 遅延ロード（sub/ 内ファイル操作時）
```

### ロード順序と優先度

| 優先度 | ソース | ロードタイミング |
|--------|--------|----------------|
| 最高 | Managed Policy (`/Library/Application Support/ClaudeCode/CLAUDE.md`) | 起動時、除外不可 |
| 高 | Project (`./CLAUDE.md` or `./.claude/CLAUDE.md`) | 起動時 |
| 中 | User (`~/.claude/CLAUDE.md`) | 起動時 |
| 低 | Subdirectory CLAUDE.md | 遅延（ファイル操作時） |

### `@import` 構文
- `@path/to/file` で外部ファイルをインラインロード
- 相対パスは CLAUDE.md からの相対（CWD ではない）
- 最大5段階のネスト
- 個人設定: `@~/.claude/my-project-instructions.md`

## .claude/rules/ の活用

### 基本構造
```
.claude/rules/
├── code-style.md      # 常時ロード
├── testing.md         # 常時ロード
├── security.md        # 常時ロード
└── frontend/
    └── react.md       # paths 指定で条件付きロード可能
```

### Path-specific Rules（条件付きロード）

```yaml
---
paths:
  - "src/api/**/*.ts"
---
```

- `paths` フロントマター付き: マッチするファイル操作時のみロード
- `paths` なし: 起動時に無条件ロード（CLAUDE.md と同等）
- コンテキスト節約に効果的

### ロード優先順: user rules → project rules（project が優先）

## Settings 優先チェーン

```
CLI 引数 (最高)
  → .claude/settings.local.json (個人・ローカル)
    → .claude/settings.json (チーム共有)
      → ~/.claude/settings.json (グローバル個人)
        → Managed Policy (組織、読み取り専用、最低)
```

- `deny` パーミッションは下位で上書き不可
- 配列は全レイヤーでマージされる

## Auto Memory のロード仕様

- `MEMORY.md` の先頭200行 or 25KB（いずれか先に到達した方）
- トピックファイル（`architecture.md` 等）は起動時ロードなし → オンデマンド
- 同一 git リポジトリ内の全 worktree で共有
- `autoMemoryDirectory` 設定でカスタムパス指定可能

## HTML コメント

CLAUDE.md 内の `<!-- comment -->` はコンテキスト注入前に除去される。
人間向けメモに使える（トークン消費なし）。コードブロック内のコメントは保持される。

## モノレポ対策

`claudeMdExcludes` で不要な CLAUDE.md を除外:
```json
{
  "claudeMdExcludes": [
    "**/other-team/CLAUDE.md"
  ]
}
```
