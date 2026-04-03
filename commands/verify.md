# プロジェクトの検証コマンドを自動検出し、順次実行してください。

## 対象: $ARGUMENTS

## 実行手順

### 1. プロジェクト検出

以下のファイルを確認し、使用可能なツールチェーンを特定:

- `package.json` → npm/yarn/pnpm
- `Cargo.toml` → cargo
- `pyproject.toml` / `setup.py` / `requirements.txt` → pip/poetry
- `go.mod` → go
- `Makefile` → make
- `Gemfile` → bundle

### 2. 順次実行

以下の順序で検証を実行する。各ステップでエラーが発生した場合は即座に停止し、エラー内容を報告する。

#### Step 1: build

プロジェクトのビルドを実行（該当する場合のみ）

#### Step 2: type check

型チェックを実行（TypeScript: `tsc --noEmit`, Python: `mypy`, 等）

#### Step 3: lint

リンターを実行（ESLint, Ruff, golangci-lint, Clippy 等）

#### Step 4: test

テストスイートを実行

#### Step 5: audit（オプション）

セキュリティ脆弱性チェック（`npm audit`, `pip audit` 等）

### 3. 結果レポート

```markdown
VERIFY REPORT
| Step | Command | Status | Duration |
|------|---------|--------|----------|
| build | [実行コマンド] | PASS/FAIL/SKIP | [時間] |
| type | [実行コマンド] | PASS/FAIL/SKIP | [時間] |
| lint | [実行コマンド] | PASS/FAIL/SKIP | [時間] |
| test | [実行コマンド] | PASS/FAIL/SKIP | [時間] |
| audit | [実行コマンド] | PASS/FAIL/SKIP | [時間] |
RESULT: ALL PASS / FAILED at [step]
```

## 注意

- 検出できなかったステップは SKIP として報告
- テストが存在しない場合は警告を出力
- CI 環境との差異がある場合は注記する
