#!/usr/bin/env bash
# behavior-test.sh - 挙動テスト
#
# 使い方:
#   bash scripts/behavior-test.sh
#
# grep/test -f ではなく、実際にコマンドを実行して exit code で判定する。

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# テスト用の一時 state.md を使用（本物を変更しない）
TEST_STATE=$(mktemp)
trap 'rm -f "$TEST_STATE"' EXIT

PASS_COUNT=0
FAIL_COUNT=0

pass() {
    echo "[PASS] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    echo "[FAIL] $1" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# state.md を作成するヘルパー
create_state() {
    local playbook="$1"
    local security="$2"
    cat > "$TEST_STATE" <<EOF
## playbook

\`\`\`yaml
active: $playbook
\`\`\`

---

## config

\`\`\`yaml
security: $security
\`\`\`
EOF
}

echo "========================================"
echo "  Behavior Tests"
echo "========================================"
echo ""
echo "Root: $ROOT"
echo ""

# contract.sh を source
source "$ROOT/scripts/contract.sh"

# テスト用に STATE_FILE を上書き
export STATE_FILE="$TEST_STATE"

# ==============================================================================
# S1: Playbook Gate Block
# playbook=null + security=admin で変更系コマンドがブロックされる
# ==============================================================================

echo "--- S1: Playbook Gate Block ---"

create_state "null" "admin"

# git add file.txt はブロックされるべき（maintenance patterns に含まれない単独ファイル）
# ただし git add -A は maintenance で許可されている
# cat > file.txt（リダイレクト）はブロックされるべき
set +e
result=$(contract_check_bash "cat > test.txt" 2>&1)
rc=$?
set -e

if [[ $rc -eq 2 ]]; then
    pass "S1.1: 'cat > test.txt' blocked with playbook=null (rc=$rc)"
else
    fail "S1.1: Expected BLOCK (rc=2) for 'cat > test.txt' but got rc=$rc"
fi

# mkdir new_dir はブロックされるべき
set +e
result=$(contract_check_bash "mkdir new_dir" 2>&1)
rc=$?
set -e

if [[ $rc -eq 2 ]]; then
    pass "S1.2: 'mkdir new_dir' blocked with playbook=null (rc=$rc)"
else
    fail "S1.2: Expected BLOCK (rc=2) for 'mkdir new_dir' but got rc=$rc"
fi

echo ""

# ==============================================================================
# S2: Playbook Active Allow
# playbook=active で変更系コマンドが許可される
# ==============================================================================

echo "--- S2: Playbook Active Allow ---"

create_state "plan/playbook-test.md" "admin"

set +e
result=$(contract_check_bash "mkdir test_dir" 2>&1)
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
    pass "S2.1: 'mkdir test_dir' allowed with playbook=active (rc=$rc)"
else
    fail "S2.1: Expected ALLOW (rc=0) for 'mkdir test_dir' with playbook=active but got rc=$rc"
fi

set +e
result=$(contract_check_bash "git add -A" 2>&1)
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
    pass "S2.2: 'git add -A' allowed with playbook=active (rc=$rc)"
else
    fail "S2.2: Expected ALLOW (rc=0) for 'git add -A' with playbook=active but got rc=$rc"
fi

echo ""

# ==============================================================================
# S3: HARD_BLOCK Protection
# HARD_BLOCK ファイルへの書き込みはブロックされる
# ==============================================================================

echo "--- S3: HARD_BLOCK Protection ---"

create_state "plan/playbook-test.md" "admin"

# CLAUDE.md への書き込みはブロック
set +e
result=$(contract_check_bash "sed -i 's/foo/bar/' CLAUDE.md" 2>&1)
rc=$?
set -e

if [[ $rc -eq 2 ]]; then
    pass "S3.1: 'sed -i ... CLAUDE.md' blocked by HARD_BLOCK (rc=$rc)"
else
    fail "S3.1: Expected BLOCK (rc=2) for CLAUDE.md edit but got rc=$rc"
fi

# is_hard_block 関数の直接テスト
if is_hard_block "CLAUDE.md"; then
    pass "S3.2: is_hard_block('CLAUDE.md') returns true"
else
    fail "S3.2: is_hard_block('CLAUDE.md') should return true"
fi

if is_hard_block "README.md"; then
    fail "S3.3: is_hard_block('README.md') should return false"
else
    pass "S3.3: is_hard_block('README.md') returns false"
fi

echo ""

# ==============================================================================
# S4: Deadlock Escape (Maintenance Operations)
# playbook=null + admin でも maintenance operations は許可される
# ==============================================================================

echo "--- S4: Deadlock Escape (Maintenance) ---"

create_state "null" "admin"

# git add -A は許可されるべき（maintenance）
set +e
result=$(contract_check_bash "git add -A" 2>&1)
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
    pass "S4.1: 'git add -A' allowed as maintenance operation (rc=$rc)"
else
    fail "S4.1: Expected ALLOW (rc=0) for 'git add -A' as maintenance but got rc=$rc"
fi

# git commit -m "..." は許可されるべき
set +e
result=$(contract_check_bash 'git commit -m "test"' 2>&1)
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
    pass "S4.2: 'git commit -m ...' allowed as maintenance operation (rc=$rc)"
else
    fail "S4.2: Expected ALLOW (rc=0) for 'git commit' as maintenance but got rc=$rc"
fi

# git checkout main は許可されるべき
set +e
result=$(contract_check_bash "git checkout main" 2>&1)
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
    pass "S4.3: 'git checkout main' allowed as maintenance operation (rc=$rc)"
else
    fail "S4.3: Expected ALLOW (rc=0) for 'git checkout main' as maintenance but got rc=$rc"
fi

# git merge feat/xxx は許可されるべき
set +e
result=$(contract_check_bash "git merge feat/test" 2>&1)
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
    pass "S4.4: 'git merge feat/test' allowed as maintenance operation (rc=$rc)"
else
    fail "S4.4: Expected ALLOW (rc=0) for 'git merge' as maintenance but got rc=$rc"
fi

echo ""

# ==============================================================================
# Summary
# ==============================================================================

echo "========================================"
echo "  Summary"
echo "========================================"
echo ""
echo "  PASS: $PASS_COUNT"
echo "  FAIL: $FAIL_COUNT"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo "[SUCCESS] All behavior tests passed"
    exit 0
else
    echo "[FAILURE] $FAIL_COUNT test(s) failed"
    exit 1
fi
