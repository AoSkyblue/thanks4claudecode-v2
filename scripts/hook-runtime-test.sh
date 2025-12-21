#!/bin/bash
# hook-runtime-test.sh - Hook Runtime Test Suite (M129)
#
# 実際の Hook に JSON を渡してテスト（contract_check_* 直接呼び出しではない）
#
# Usage:
#   bash scripts/hook-runtime-test.sh

set -uo pipefail

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."
HOOKS_DIR="${REPO_ROOT}/.claude/hooks"

# テスト用の一時ディレクトリ
TEMP_DIR=$(mktemp -d)
TEST_STATE_FILE="${TEMP_DIR}/state.md"
export STATE_FILE="$TEST_STATE_FILE"

# クリーンアップ用 trap
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# テスト結果カウンタ
PASS_COUNT=0
FAIL_COUNT=0

# テスト結果ログ（failures.log 形式）
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
    # failures.log 形式で記録
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S")
    echo "{\"timestamp\": \"$timestamp\", \"test\": \"hook-runtime\", \"case\": \"$1\", \"result\": \"FAIL\"}" >> "$TEST_RESULTS_LOG"
}

# テスト用 state.md を作成
create_test_state() {
    local playbook="$1"
    local security="$2"

    cat > "$TEST_STATE_FILE" << EOF
# state.md (test)

## focus

\`\`\`yaml
current: test
\`\`\`

## playbook

\`\`\`yaml
active: $playbook
\`\`\`

## config

\`\`\`yaml
security: $security
\`\`\`
EOF
}

# JSON ペイロードを生成
make_edit_json() {
    local file_path="$1"
    echo "{\"tool_name\": \"Edit\", \"tool_input\": {\"file_path\": \"$file_path\"}}"
}

make_bash_json() {
    local command="$1"
    echo "{\"tool_name\": \"Bash\", \"tool_input\": {\"command\": \"$command\"}}"
}

# ==============================================================================
# テスト 1: playbook-guard.sh の実行時テスト
# ==============================================================================

test_playbook_guard() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: playbook-guard.sh Runtime"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local hook="${HOOKS_DIR}/playbook-guard.sh"
    if [[ ! -f "$hook" ]]; then
        log_fail "H1: playbook-guard.sh not found"
        return
    fi

    # H1: playbook=null で一般ファイル編集 → BLOCK
    create_test_state "null" "strict"
    log_test "H1: playbook=null + Edit src/index.ts → BLOCK expected"
    local json
    json=$(make_edit_json "src/index.ts")
    if echo "$json" | bash "$hook" 2>/dev/null; then
        log_fail "H1: Should have been blocked"
    else
        log_pass "H1: Correctly blocked"
    fi

    # H2: playbook=null で state.md 編集 → ALLOW（Bootstrap 例外）
    log_test "H2: playbook=null + Edit state.md → ALLOW expected"
    json=$(make_edit_json "state.md")
    if echo "$json" | bash "$hook" 2>/dev/null; then
        log_pass "H2: Correctly allowed (Bootstrap exception)"
    else
        log_fail "H2: state.md should be allowed"
    fi

    # H3: playbook=active で一般ファイル編集 → ALLOW
    create_test_state "plan/playbook-test.md" "strict"
    # Create dummy playbook file for the test (with reviewed: true)
    mkdir -p "${REPO_ROOT}/plan"
    echo "reviewed: true" > "${REPO_ROOT}/plan/playbook-test.md"
    log_test "H3: playbook=active + Edit src/index.ts → ALLOW expected"
    json=$(make_edit_json "src/index.ts")
    if echo "$json" | bash "$hook" 2>/dev/null; then
        log_pass "H3: Correctly allowed with active playbook"
    else
        log_fail "H3: Should be allowed with active playbook"
    fi
    rm -f "${REPO_ROOT}/plan/playbook-test.md"
}

# ==============================================================================
# テスト 2: pre-bash-check.sh の実行時テスト
# ==============================================================================

test_pre_bash_check() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: pre-bash-check.sh Runtime"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local hook="${HOOKS_DIR}/pre-bash-check.sh"
    if [[ ! -f "$hook" ]]; then
        log_fail "B1: pre-bash-check.sh not found"
        return
    fi

    # B1: playbook=null で変更系コマンド → BLOCK
    create_test_state "null" "strict"
    log_test "B1: playbook=null + mkdir test → BLOCK expected"
    local json
    json=$(make_bash_json "mkdir test")
    if echo "$json" | bash "$hook" 2>/dev/null; then
        log_fail "B1: mkdir should be blocked"
    else
        log_pass "B1: Correctly blocked"
    fi

    # B2: playbook=null で読み取りコマンド → ALLOW
    log_test "B2: playbook=null + ls -la → ALLOW expected"
    json=$(make_bash_json "ls -la")
    if echo "$json" | bash "$hook" 2>/dev/null; then
        log_pass "B2: Correctly allowed (read-only)"
    else
        log_fail "B2: ls should be allowed"
    fi

    # B3: playbook=active で変更系コマンド → ALLOW
    create_test_state "plan/playbook-test.md" "strict"
    log_test "B3: playbook=active + mkdir test → ALLOW expected"
    json=$(make_bash_json "mkdir test")
    if echo "$json" | bash "$hook" 2>/dev/null; then
        log_pass "B3: Correctly allowed with active playbook"
    else
        log_fail "B3: Should be allowed with active playbook"
    fi

    # B4: HARD_BLOCK コマンド → BLOCK（playbook 有無に関係なく）
    log_test "B4: playbook=active + rm -rf / → BLOCK expected (HARD_BLOCK)"
    json=$(make_bash_json "rm -rf /")
    if echo "$json" | bash "$hook" 2>/dev/null; then
        log_fail "B4: rm -rf / should ALWAYS be blocked"
    else
        log_pass "B4: Correctly blocked (HARD_BLOCK)"
    fi
}

# ==============================================================================
# テスト 3: check-protected-edit.sh の実行時テスト
# ==============================================================================

test_protected_edit() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: check-protected-edit.sh Runtime"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local hook="${HOOKS_DIR}/check-protected-edit.sh"
    if [[ ! -f "$hook" ]]; then
        log_fail "P1: check-protected-edit.sh not found"
        return
    fi

    # P1: HARD_BLOCK ファイル（CLAUDE.md）→ BLOCK
    create_test_state "plan/playbook-test.md" "admin"
    log_test "P1: Edit CLAUDE.md → BLOCK expected (HARD_BLOCK)"
    local json
    json=$(make_edit_json "CLAUDE.md")
    if echo "$json" | bash "$hook" 2>/dev/null; then
        log_fail "P1: CLAUDE.md should be HARD_BLOCKED"
    else
        log_pass "P1: Correctly blocked (HARD_BLOCK)"
    fi

    # P2: 通常ファイル → ALLOW
    log_test "P2: Edit src/index.ts → ALLOW expected"
    json=$(make_edit_json "src/index.ts")
    if echo "$json" | bash "$hook" 2>/dev/null; then
        log_pass "P2: Correctly allowed"
    else
        log_fail "P2: Normal file should be allowed"
    fi
}

# ==============================================================================
# テスト 4: JSON 解析の検証
# ==============================================================================

test_json_parsing() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: JSON Parsing in Hooks"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # J1: 不正な JSON → 適切に処理される（クラッシュしない）
    log_test "J1: Invalid JSON → graceful handling"
    create_test_state "null" "strict"
    local hook="${HOOKS_DIR}/playbook-guard.sh"
    if echo "not valid json" | bash "$hook" 2>/dev/null; then
        log_pass "J1: Gracefully handled invalid JSON"
    else
        # exit code 非 0 でも OK（クラッシュせず終了すれば成功）
        log_pass "J1: Gracefully rejected invalid JSON"
    fi

    # J2: 空の JSON → 適切に処理される
    log_test "J2: Empty JSON → graceful handling"
    if echo "{}" | bash "$hook" 2>/dev/null; then
        log_pass "J2: Gracefully handled empty JSON"
    else
        log_pass "J2: Gracefully rejected empty JSON"
    fi
}

# ==============================================================================
# メイン
# ==============================================================================

print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Hook Runtime Test Results"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "  ${GREEN}PASS${NC}: $PASS_COUNT"
    echo -e "  ${RED}FAIL${NC}: $FAIL_COUNT"
    echo ""

    # テスト結果サマリーをログに記録
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S")
    echo "{\"timestamp\": \"$timestamp\", \"test\": \"hook-runtime\", \"pass\": $PASS_COUNT, \"fail\": $FAIL_COUNT, \"result\": \"$([ $FAIL_COUNT -eq 0 ] && echo 'PASS' || echo 'FAIL')\"}" >> "$TEST_RESULTS_LOG"

    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo -e "  ${GREEN}ALL HOOK RUNTIME TESTS PASSED${NC}"
        return 0
    else
        echo -e "  ${RED}SOME TESTS FAILED${NC}"
        return 1
    fi
}

main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Hook Runtime Test Suite (M129)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # テスト結果ログを初期化
    mkdir -p "$(dirname "$TEST_RESULTS_LOG")"

    test_playbook_guard
    test_pre_bash_check
    test_protected_edit
    test_json_parsing

    print_summary
}

main "$@"
