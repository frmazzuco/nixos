#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

assert_contains() {
  local file="$1"
  local needle="$2"

  if ! rg -Fq "$needle" "$file"; then
    printf 'Missing expected text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

assert_not_contains() {
  local file="$1"
  local needle="$2"

  if rg -Fq "$needle" "$file"; then
    printf 'Unexpected stale text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

assert_contains docs/qwen35-9b.md '`ctx-size=131072`'
assert_contains docs/qwen35-9b.md '`QWEN35_9B_CTX=131072`'
assert_contains docs/qwen35-9b.md '`cache-type-k=q4_0`'
assert_contains docs/qwen35-9b.md '`cache-type-v=q4_0`'
assert_contains docs/qwen35-9b.md '`QWEN35_9B_CACHE_K=q4_0`'
assert_contains docs/qwen35-9b.md '`QWEN35_9B_CACHE_V=q4_0`'
assert_contains docs/qwen35-9b.md 'sobe por padrao na sessao do usuario'
assert_contains docs/qwen35-9b.md '`http://127.0.0.1:8080`'
assert_not_contains docs/qwen35-9b.md '`ctx-size=8192`'

assert_contains docs/qwen35-a3b.md '`QWEN35_A3B_PROFILE=thinking-general`'
assert_contains docs/qwen35-a3b.md 'o preset de servico padrao do modulo usa `thinking-general`'
assert_not_contains docs/qwen35-a3b.md 'desativado no server com `--reasoning-budget 0` e `--reasoning-format none`'

assert_contains docs/qwen35-27b-unsloth.md '`port=8082`'
assert_contains docs/qwen35-27b-unsloth.md '`http://127.0.0.1:8082`'

printf 'AI docs sync contract OK\n'
