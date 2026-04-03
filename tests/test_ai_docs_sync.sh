#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
cd "$repo_root"

assert_contains() {
  local file="$1"
  local needle="$2"

  require_fixed "$needle" "$file"
}

assert_not_contains() {
  local file="$1"
  local needle="$2"

  reject_fixed "$needle" "$file"
}

assert_contains docs/qwen35-9b.md '`ctx-size=131072`'
assert_contains docs/qwen35-9b.md '`QWEN35_9B_CTX=131072`'
assert_contains docs/qwen35-9b.md '`QWEN35_9B_PROFILE=thinking-general`'
assert_contains docs/qwen35-9b.md '`cache-type-k=q4_0`'
assert_contains docs/qwen35-9b.md '`cache-type-v=q4_0`'
assert_contains docs/qwen35-9b.md '`QWEN35_9B_CACHE_K=q4_0`'
assert_contains docs/qwen35-9b.md '`QWEN35_9B_CACHE_V=q4_0`'
assert_contains docs/qwen35-9b.md 'o preset padrao do modulo'
assert_contains docs/qwen35-9b.md 'agora fica como preset manual'
assert_contains docs/qwen35-9b.md '`http://127.0.0.1:8080`'
assert_not_contains docs/qwen35-9b.md '`ctx-size=8192`'

assert_contains docs/gemma4-e4b.md '`ctx-size=131072`'
assert_contains docs/gemma4-e4b.md '`cache-type-k=f16`'
assert_contains docs/gemma4-e4b.md '`cache-type-v=f16`'
assert_contains docs/gemma4-e4b.md 'sobe por padrao na sessao do usuario'
assert_contains docs/gemma4-e4b.md '`http://127.0.0.1:18083`'
assert_contains docs/gemma4-e4b.md '`provider_kind=openai-compat`'

assert_contains docs/gemma4-26b.md 'fica como preset manual'
assert_contains docs/gemma4-26b.md '`ctx-size=68000`'

printf 'AI docs sync contract OK\n'
