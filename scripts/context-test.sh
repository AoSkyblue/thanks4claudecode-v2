#!/bin/bash
# context-test.sh - コンテキスト保持機構テスト（M129）
#
# session-start.sh と pre-compact.sh の動作検証
#
# Usage:
#   bash scripts/context-test.sh

set -uo pipefail

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."
HOOKS_DIR="${REPO_ROOT}/.claude/hooks"
INIT_DIR="${REPO_ROOT}/.claude/.session-init"

# テスト結果カウンタ
PASS_COUNT=0
FAIL_COUNT=0

# テスト結果ログ
TEST_RESULTS_LOG="${REPO_ROOT}/.claude/logs/test-results.log"

# ==============================================================================
# ヘルパー関数
# ==============================================================================

log_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL_COUNT++))
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S")
    echo "{\"timestamp\": \"$timestamp\", \"test\": \"context\", \"case\": \"$1\", \"result\": \"FAIL\"}" >> "$TEST_RESULTS_LOG"
}

# ==============================================================================
# session-start.sh テスト
# ==============================================================================

test_session_start() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: session-start.sh"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local hook="${HOOKS_DIR}/session-start.sh"

    # SS1: スクリプトが存在
    log_test "SS1: session-start.sh exists"
    if [[ -f "$hook" ]]; then
        log_pass "SS1: session-start.sh exists"
    else
        log_fail "SS1: session-start.sh not found"
        return
    fi

    # SS2: 構文エラーがない
    log_test "SS2: session-start.sh is syntactically valid"
    if bash -n "$hook" 2>/dev/null; then
        log_pass "SS2: No syntax errors"
    else
        log_fail "SS2: Syntax errors detected"
    fi

    # SS3: 実行すると出力が生成される
    log_test "SS3: session-start.sh produces output"
    local output
    output=$(bash "$hook" 2>&1 || true)
    if [[ -n "$output" ]]; then
        log_pass "SS3: Output generated"
    else
        log_fail "SS3: No output generated"
    fi

    # SS4: 動線サマリーセクションを含む
    log_test "SS4: Output contains flow summary section"
    if echo "$output" | grep -q "動線サマリー\|動線単位"; then
        log_pass "SS4: Flow summary section present"
    else
        log_fail "SS4: Flow summary section not found"
    fi

    # SS5: CORE セクションを含む
    log_test "SS5: Output contains CORE section"
    if echo "$output" | grep -q "CORE"; then
        log_pass "SS5: CORE section present"
    else
        log_fail "SS5: CORE section not found"
    fi

    # SS6: failures.log の読み込み処理を含む
    log_test "SS6: session-start.sh reads failures.log"
    if grep -q "failures.log" "$hook" 2>/dev/null; then
        log_pass "SS6: failures.log reading implemented"
    else
        log_fail "SS6: failures.log reading not implemented"
    fi
}

# ==============================================================================
# pre-compact.sh テスト
# ==============================================================================

test_pre_compact() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: pre-compact.sh"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local hook="${HOOKS_DIR}/pre-compact.sh"

    # PC1: スクリプトが存在
    log_test "PC1: pre-compact.sh exists"
    if [[ -f "$hook" ]]; then
        log_pass "PC1: pre-compact.sh exists"
    else
        log_fail "PC1: pre-compact.sh not found"
        return
    fi

    # PC2: 構文エラーがない
    log_test "PC2: pre-compact.sh is syntactically valid"
    if bash -n "$hook" 2>/dev/null; then
        log_pass "PC2: No syntax errors"
    else
        log_fail "PC2: Syntax errors detected"
    fi

    # PC3: 実行すると snapshot.json が生成される
    log_test "PC3: pre-compact.sh creates snapshot.json"
    # バックアップ
    local backup=""
    if [[ -f "${INIT_DIR}/snapshot.json" ]]; then
        backup=$(cat "${INIT_DIR}/snapshot.json")
    fi

    # 実行
    echo '{"trigger": "test"}' | bash "$hook" >/dev/null 2>&1 || true

    if [[ -f "${INIT_DIR}/snapshot.json" ]]; then
        log_pass "PC3: snapshot.json created"
    else
        log_fail "PC3: snapshot.json not created"
    fi

    # リストア（テストで上書きしたものを元に戻す必要がある場合）

    # PC4: snapshot.json が有効な JSON
    log_test "PC4: snapshot.json is valid JSON"
    if [[ -f "${INIT_DIR}/snapshot.json" ]]; then
        if jq empty "${INIT_DIR}/snapshot.json" 2>/dev/null; then
            log_pass "PC4: Valid JSON"
        else
            log_fail "PC4: Invalid JSON"
        fi
    else
        log_fail "PC4: snapshot.json not found"
    fi

    # PC5: snapshot.json に必須フィールドを含む
    log_test "PC5: snapshot.json contains required fields"
    if [[ -f "${INIT_DIR}/snapshot.json" ]]; then
        local has_fields=true
        for field in timestamp focus playbook branch; do
            if ! jq -e ".$field" "${INIT_DIR}/snapshot.json" >/dev/null 2>&1; then
                has_fields=false
                break
            fi
        done
        if [[ "$has_fields" == "true" ]]; then
            log_pass "PC5: Required fields present"
        else
            log_fail "PC5: Missing required fields"
        fi
    else
        log_fail "PC5: snapshot.json not found"
    fi

    # PC6: additionalContext を出力
    log_test "PC6: pre-compact.sh outputs additionalContext"
    local output
    output=$(echo '{"trigger": "test"}' | bash "$hook" 2>/dev/null || true)
    if echo "$output" | jq -e '.additionalContext' >/dev/null 2>&1; then
        log_pass "PC6: additionalContext output"
    else
        log_fail "PC6: additionalContext not in output"
    fi
}

# ==============================================================================
# snapshot.json 連携テスト
# ==============================================================================

test_snapshot_integration() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: Snapshot Integration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # SI1: .session-init ディレクトリが存在
    log_test "SI1: .session-init directory exists"
    if [[ -d "$INIT_DIR" ]]; then
        log_pass "SI1: Directory exists"
    else
        log_fail "SI1: Directory not found"
    fi

    # SI2: snapshot.json が現在の playbook と一致
    log_test "SI2: snapshot.json playbook matches state.md"
    if [[ -f "${INIT_DIR}/snapshot.json" && -f "${REPO_ROOT}/state.md" ]]; then
        local snapshot_playbook
        local state_playbook
        snapshot_playbook=$(jq -r '.playbook // ""' "${INIT_DIR}/snapshot.json" 2>/dev/null)
        state_playbook=$(grep -A6 "^## playbook" "${REPO_ROOT}/state.md" 2>/dev/null | grep "^active:" | head -1 | sed 's/active: *//' | sed 's/ *#.*//' | tr -d ' ')

        if [[ "$snapshot_playbook" == "$state_playbook" ]]; then
            log_pass "SI2: Playbook matches"
        else
            log_fail "SI2: Playbook mismatch (snapshot: '$snapshot_playbook', state: '$state_playbook')"
        fi
    else
        log_fail "SI2: Required files not found"
    fi

    # SI3: snapshot.json の branch が現在の git branch と一致
    log_test "SI3: snapshot.json branch matches git branch"
    if [[ -f "${INIT_DIR}/snapshot.json" ]]; then
        local snapshot_branch
        local git_branch
        snapshot_branch=$(jq -r '.branch // ""' "${INIT_DIR}/snapshot.json" 2>/dev/null)
        git_branch=$(git -C "${REPO_ROOT}" branch --show-current 2>/dev/null)

        if [[ "$snapshot_branch" == "$git_branch" ]]; then
            log_pass "SI3: Branch matches"
        else
            log_fail "SI3: Branch mismatch (snapshot: '$snapshot_branch', git: '$git_branch')"
        fi
    else
        log_fail "SI3: snapshot.json not found"
    fi
}

# ==============================================================================
# メイン
# ==============================================================================

print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Context Test Results"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "  ${GREEN}PASS${NC}: $PASS_COUNT"
    echo -e "  ${RED}FAIL${NC}: $FAIL_COUNT"
    echo ""

    # テスト結果サマリーをログに記録
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S")
    echo "{\"timestamp\": \"$timestamp\", \"test\": \"context\", \"pass\": $PASS_COUNT, \"fail\": $FAIL_COUNT, \"result\": \"$([ $FAIL_COUNT -eq 0 ] && echo 'PASS' || echo 'FAIL')\"}" >> "$TEST_RESULTS_LOG"

    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo -e "  ${GREEN}ALL CONTEXT TESTS PASSED${NC}"
        return 0
    else
        echo -e "  ${RED}SOME TESTS FAILED${NC}"
        return 1
    fi
}

main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Context Preservation Test Suite (M129)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    mkdir -p "$(dirname "$TEST_RESULTS_LOG")"

    test_session_start
    test_pre_compact
    test_snapshot_integration

    print_summary
}

main "$@"
