#!/usr/bin/env bash
# Config Protection Hook
# Blocks modifications to linter/formatter config files.
# Fix the code, don't weaken the rules.
set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')

# Protected config file patterns
protected_patterns=(
  '.eslintrc'
  '.eslintrc.js'
  '.eslintrc.json'
  '.eslintrc.yml'
  'eslint.config.js'
  'eslint.config.mjs'
  'eslint.config.ts'
  '.prettierrc'
  '.prettierrc.js'
  '.prettierrc.json'
  'prettier.config.js'
  'prettier.config.mjs'
  '.stylelintrc'
  '.stylelintrc.json'
  'biome.json'
  'biome.jsonc'
  '.flake8'
  'pyproject.toml'
  'ruff.toml'
  '.ruff.toml'
)

basename_file=$(basename "$file_path")

for pattern in "${protected_patterns[@]}"; do
  if [[ "$basename_file" == "$pattern" ]]; then
    echo "[Hook] BLOCKED: Modification to config file '$basename_file' is not allowed." >&2
    echo "[Hook] Fix the code to comply with the existing config instead of weakening the rules." >&2
    exit 1
  fi
done

# tsconfig.json — allow but warn
if [[ "$basename_file" == "tsconfig.json" || "$basename_file" == "tsconfig.*.json" ]]; then
  echo "[Hook] WARNING: Modifying TypeScript config '$basename_file'. Ensure this is intentional." >&2
fi

printf '%s\n' "$input"
