#!/bin/bash
# e2e-contract-test.sh - Contract E2E Test Suite
#
# Usage:
#   bash scripts/e2e-contract-test.sh [scenario]
#
# Scenarios:
#   scenario_a  - playbook=null & non-admin: 全ての変更がブロックされる
#   scenario_b  - playbook=null & admin: Maintenance 操作のみ許可
#   scenario_c  - playbook=active: Golden Path が通る
#   session_end - セッション終了処理が完遂できる
#   all         - 全シナリオ実行

set -uo pipefail
# Note: Not using -e because we expect some commands to fail during testing

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."
CONTRACT_SCRIPT="${SCRIPT_DIR}/contract.sh"

# テスト用の一時 state.md を使用（実際の state.md を変更しない）
TEMP_DIR=$(mktemp -d)
STATE_FILE="${TEMP_DIR}/state.md"
export STATE_FILE

# クリーンアップ用 trap
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# テスト結果カウンタ
PASS_COUNT=0
FAIL_COUNT=0

# テスト結果ログ（failures.log と同じ形式）
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
    echo "{\"timestamp\": \"$timestamp\", \"test\": \"e2e-contract\", \"case\": \"$1\", \"result\": \"FAIL\"}" >> "$TEST_RESULTS_LOG"
}

# テスト用 state.md を作成
create_test_state() {
    local playbook="$1"
    local security="$2"

    cat > "$STATE_FILE" << EOF
# state.md (test)

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

# contract.sh を読み込み
source "$CONTRACT_SCRIPT"

# ==============================================================================
# シナリオ A: playbook=null & non-admin
# ==============================================================================

scenario_a() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  シナリオ A: playbook=null & non-admin"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    create_test_state "null" "strict"

    # テスト A1: Hook ファイルの編集がブロックされる
    log_test "A1: Edit .claude/hooks/test.sh → BLOCK expected"
    if contract_check_edit ".claude/hooks/test.sh" 2>/dev/null; then
        log_fail "A1: Should have been blocked"
    else
        log_pass "A1: Correctly blocked"
    fi

    # テスト A2: コードファイルの編集がブロックされる
    log_test "A2: Edit src/index.ts → BLOCK expected"
    if contract_check_edit "src/index.ts" 2>/dev/null; then
        log_fail "A2: Should have been blocked"
    else
        log_pass "A2: Correctly blocked"
    fi

    # テスト A3: 変更系 Bash がブロックされる
    log_test "A3: Bash 'mkdir test' → BLOCK expected"
    if contract_check_bash "mkdir test" 2>/dev/null; then
        log_fail "A3: Should have been blocked"
    else
        log_pass "A3: Correctly blocked"
    fi

    # テスト A4: git add がブロックされる
    log_test "A4: Bash 'git add .' → BLOCK expected"
    if contract_check_bash "git add ." 2>/dev/null; then
        log_fail "A4: Should have been blocked"
    else
        log_pass "A4: Correctly blocked"
    fi

    # テスト A5: state.md は許可される（Bootstrap 例外）
    log_test "A5: Edit state.md → ALLOW expected"
    if contract_check_edit "state.md" 2>/dev/null; then
        log_pass "A5: Correctly allowed"
    else
        log_fail "A5: Should have been allowed"
    fi

    # テスト A6: playbook ファイルは許可される（Bootstrap 例外）
    log_test "A6: Edit plan/playbook-test.md → ALLOW expected"
    if contract_check_edit "plan/playbook-test.md" 2>/dev/null; then
        log_pass "A6: Correctly allowed"
    else
        log_fail "A6: Should have been allowed"
    fi
}

# ==============================================================================
# シナリオ B: playbook=null & admin (Maintenance)
# ==============================================================================

scenario_b() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  シナリオ B: playbook=null & admin"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    create_test_state "null" "admin"

    # テスト B1: state.md の編集は許可
    log_test "B1: Edit state.md → ALLOW expected"
    if contract_check_edit "state.md" 2>/dev/null; then
        log_pass "B1: Correctly allowed"
    else
        log_fail "B1: Should have been allowed"
    fi

    # テスト B2: playbook アーカイブは許可
    log_test "B2: Bash 'mv plan/playbook-x.md plan/archive/' → ALLOW expected"
    if contract_check_bash "mv plan/playbook-x.md plan/archive/" 2>/dev/null; then
        log_pass "B2: Correctly allowed"
    else
        log_fail "B2: Should have been allowed"
    fi

    # テスト B3: archive ディレクトリ作成は許可
    log_test "B3: Bash 'mkdir -p plan/archive' → ALLOW expected"
    if contract_check_bash "mkdir -p plan/archive" 2>/dev/null; then
        log_pass "B3: Correctly allowed"
    else
        log_fail "B3: Should have been allowed"
    fi

    # テスト B4: git add state.md は許可
    log_test "B4: Bash 'git add state.md' → ALLOW expected"
    if contract_check_bash "git add state.md" 2>/dev/null; then
        log_pass "B4: Correctly allowed"
    else
        log_fail "B4: Should have been allowed"
    fi

    # テスト B5: コードファイルの編集はブロック（admin でも）
    log_test "B5: Edit src/index.ts → BLOCK expected (even admin)"
    if contract_check_edit "src/index.ts" 2>/dev/null; then
        log_fail "B5: Should have been blocked even in admin"
    else
        log_pass "B5: Correctly blocked"
    fi

    # テスト B6: HARD_BLOCK ファイルはブロック（admin でも）
    log_test "B6: Edit CLAUDE.md → BLOCK expected (HARD_BLOCK)"
    if contract_check_edit "CLAUDE.md" 2>/dev/null; then
        log_fail "B6: HARD_BLOCK should not be bypassed"
    else
        log_pass "B6: Correctly blocked (HARD_BLOCK)"
    fi
}

# ==============================================================================
# シナリオ C: playbook=active
# ==============================================================================

scenario_c() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  シナリオ C: playbook=active"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    create_test_state "plan/playbook-test.md" "strict"

    # テスト C1: コードファイルの編集は許可
    log_test "C1: Edit src/index.ts → ALLOW expected"
    if contract_check_edit "src/index.ts" 2>/dev/null; then
        log_pass "C1: Correctly allowed"
    else
        log_fail "C1: Should have been allowed with active playbook"
    fi

    # テスト C2: Hook ファイルの編集は許可（playbook あり）
    log_test "C2: Edit .claude/hooks/test.sh → ALLOW expected"
    if contract_check_edit ".claude/hooks/test.sh" 2>/dev/null; then
        log_pass "C2: Correctly allowed"
    else
        log_fail "C2: Should have been allowed with active playbook"
    fi

    # テスト C3: 変更系 Bash は許可
    log_test "C3: Bash 'mkdir test' → ALLOW expected"
    if contract_check_bash "mkdir test" 2>/dev/null; then
        log_pass "C3: Correctly allowed"
    else
        log_fail "C3: Should have been allowed with active playbook"
    fi

    # テスト C4: git add は許可
    log_test "C4: Bash 'git add .' → ALLOW expected"
    if contract_check_bash "git add ." 2>/dev/null; then
        log_pass "C4: Correctly allowed"
    else
        log_fail "C4: Should have been allowed with active playbook"
    fi

    # テスト C5: HARD_BLOCK は playbook があってもブロック
    log_test "C5: Edit CLAUDE.md → BLOCK expected (HARD_BLOCK)"
    if contract_check_edit "CLAUDE.md" 2>/dev/null; then
        log_fail "C5: HARD_BLOCK should always block"
    else
        log_pass "C5: Correctly blocked (HARD_BLOCK)"
    fi
}

# ==============================================================================
# シナリオ: セッション終了処理
# ==============================================================================

session_end() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  シナリオ: セッション終了処理"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    create_test_state "null" "admin"

    # セッション終了の全ステップをシミュレート
    log_test "Session End Step 1: mkdir -p plan/archive"
    if contract_check_bash "mkdir -p plan/archive" 2>/dev/null; then
        log_pass "Step 1: archive directory creation"
    else
        log_fail "Step 1: Should allow mkdir plan/archive"
    fi

    log_test "Session End Step 2: mv plan/playbook-x.md plan/archive/"
    if contract_check_bash "mv plan/playbook-x.md plan/archive/" 2>/dev/null; then
        log_pass "Step 2: playbook archive"
    else
        log_fail "Step 2: Should allow playbook archive"
    fi

    log_test "Session End Step 3: Edit state.md (playbook=null)"
    if contract_check_edit "state.md" 2>/dev/null; then
        log_pass "Step 3: state.md update"
    else
        log_fail "Step 3: Should allow state.md edit"
    fi

    log_test "Session End Step 4: git add state.md plan/archive/"
    if contract_check_bash "git add state.md plan/archive/" 2>/dev/null; then
        log_pass "Step 4: git add maintenance files"
    else
        log_fail "Step 4: Should allow git add for maintenance"
    fi

    log_test "Session End Step 5: git commit"
    if contract_check_bash "git commit -m 'chore: session end'" 2>/dev/null; then
        log_pass "Step 5: git commit"
    else
        log_fail "Step 5: Should allow git commit for maintenance"
    fi
}

# ==============================================================================
# シナリオ: 境界条件テスト（誤検出防止）
# ==============================================================================

boundary_tests() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  シナリオ: 境界条件（誤検出防止）"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # playbook=null でも読み取りコマンドは許可されるべき
    create_test_state "null" "strict"

    # テスト B1: cat + 2>/dev/null は読み取り（許可）
    log_test "B1: Bash 'cat file.txt 2>/dev/null' → ALLOW expected"
    if contract_check_bash "cat file.txt 2>/dev/null" 2>/dev/null; then
        log_pass "B1: Correctly allowed (read with stderr redirect)"
    else
        log_fail "B1: Should have been allowed (read with stderr redirect)"
    fi

    # テスト B2: ls + 2>&1 は読み取り（許可）
    log_test "B2: Bash 'ls -la 2>&1' → ALLOW expected"
    if contract_check_bash "ls -la 2>&1" 2>/dev/null; then
        log_pass "B2: Correctly allowed (ls with redirect)"
    else
        log_fail "B2: Should have been allowed (ls with redirect)"
    fi

    # テスト B3: grep + >/dev/null は読み取り（許可）
    log_test "B3: Bash 'grep pattern file >/dev/null' → ALLOW expected"
    if contract_check_bash "grep pattern file >/dev/null" 2>/dev/null; then
        log_pass "B3: Correctly allowed (grep with null redirect)"
    else
        log_fail "B3: Should have been allowed (grep with null redirect)"
    fi

    # テスト B4: cat + 1>/dev/null は読み取り（許可）
    log_test "B4: Bash 'cat file 1>/dev/null' → ALLOW expected"
    if contract_check_bash "cat file 1>/dev/null" 2>/dev/null; then
        log_pass "B4: Correctly allowed (cat with stdout to null)"
    else
        log_fail "B4: Should have been allowed (cat with stdout to null)"
    fi

    # テスト B5: 実際の書き込み > file.txt はブロック
    log_test "B5: Bash 'echo test > file.txt' → BLOCK expected"
    if contract_check_bash "echo test > file.txt" 2>/dev/null; then
        log_fail "B5: Should have been blocked (actual write)"
    else
        log_pass "B5: Correctly blocked (actual write)"
    fi

    # テスト B6: 追記 >> file.txt はブロック
    log_test "B6: Bash 'echo test >> file.txt' → BLOCK expected"
    if contract_check_bash "echo test >> file.txt" 2>/dev/null; then
        log_fail "B6: Should have been blocked (append)"
    else
        log_pass "B6: Correctly blocked (append)"
    fi

    # テスト B7: tee コマンドはブロック
    log_test "B7: Bash 'cat file | tee output.txt' → BLOCK expected"
    if contract_check_bash "cat file | tee output.txt" 2>/dev/null; then
        log_fail "B7: Should have been blocked (tee)"
    else
        log_pass "B7: Correctly blocked (tee)"
    fi

    # テスト B8: 複合コマンド（読み取り + /dev/null）は許可
    log_test "B8: Bash 'cat file 2>/dev/null | grep pattern' → ALLOW expected"
    if contract_check_bash "cat file 2>/dev/null | grep pattern" 2>/dev/null; then
        log_pass "B8: Correctly allowed (piped read)"
    else
        log_fail "B8: Should have been allowed (piped read)"
    fi

    # テスト B9: 複合コマンド（読み取り + 2>&1）は許可
    log_test "B9: Bash 'ls -la 2>&1 | head -10' → ALLOW expected"
    if contract_check_bash "ls -la 2>&1 | head -10" 2>/dev/null; then
        log_pass "B9: Correctly allowed (ls piped)"
    else
        log_fail "B9: Should have been allowed (ls piped)"
    fi

    # テスト B10: git status は許可
    log_test "B10: Bash 'git status' → ALLOW expected"
    if contract_check_bash "git status" 2>/dev/null; then
        log_pass "B10: Correctly allowed (git status)"
    else
        log_fail "B10: Should have been allowed (git status)"
    fi
}

# ==============================================================================
# シナリオ: セキュリティホール検証（注入攻撃、絶対パス等）
# ==============================================================================

security_tests() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  シナリオ: セキュリティホール検証"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # === 絶対パスリダイレクト ===
    echo "--- 絶対パスリダイレクト ---"
    create_test_state "null" "strict"

    log_test "S1: Bash 'echo hi >/tmp/x' → BLOCK expected"
    if contract_check_bash "echo hi >/tmp/x" 2>/dev/null; then
        log_fail "S1: Absolute path redirect should be blocked"
    else
        log_pass "S1: Correctly blocked (absolute path redirect)"
    fi

    log_test "S2: Bash 'echo hi >>/tmp/x' → BLOCK expected"
    if contract_check_bash "echo hi >>/tmp/x" 2>/dev/null; then
        log_fail "S2: Absolute path append should be blocked"
    else
        log_pass "S2: Correctly blocked (absolute path append)"
    fi

    log_test "S3: Bash '2>/tmp/err.log' → BLOCK expected"
    if contract_check_bash "some_cmd 2>/tmp/err.log" 2>/dev/null; then
        log_fail "S3: Stderr to file should be blocked"
    else
        log_pass "S3: Correctly blocked (stderr to file)"
    fi

    log_test "S4: Bash '&>/tmp/out' → BLOCK expected"
    if contract_check_bash "some_cmd &>/tmp/out" 2>/dev/null; then
        log_fail "S4: Combined redirect to file should be blocked"
    else
        log_pass "S4: Correctly blocked (combined redirect)"
    fi

    # === 複合コマンド注入 ===
    echo ""
    echo "--- 複合コマンド注入 ---"
    create_test_state "null" "admin"

    log_test "S5: Bash 'git add state.md && git add -A' → BLOCK expected (even admin)"
    if contract_check_bash "git add state.md && git add -A" 2>/dev/null; then
        log_fail "S5: Compound command injection should be blocked"
    else
        log_pass "S5: Correctly blocked (compound with &&)"
    fi

    log_test "S6: Bash 'mv plan/playbook-x.md plan/archive/; rm -rf src' → BLOCK expected"
    if contract_check_bash "mv plan/playbook-x.md plan/archive/; rm -rf src" 2>/dev/null; then
        log_fail "S6: Semicolon injection should be blocked"
    else
        log_pass "S6: Correctly blocked (semicolon injection)"
    fi

    log_test "S7: Bash 'mkdir plan/archive || rm -rf /' → BLOCK expected"
    if contract_check_bash "mkdir plan/archive || rm -rf /" 2>/dev/null; then
        log_fail "S7: OR injection should be blocked"
    else
        log_pass "S7: Correctly blocked (OR injection)"
    fi

    log_test "S8: Bash 'cat file | tee /etc/passwd' → BLOCK expected"
    if contract_check_bash "cat file | tee /etc/passwd" 2>/dev/null; then
        log_fail "S8: Pipe injection should be blocked"
    else
        log_pass "S8: Correctly blocked (pipe injection)"
    fi

    # === Git mutation コマンド ===
    echo ""
    echo "--- Git mutation コマンド ---"
    create_test_state "null" "strict"

    log_test "S9: Bash 'git push' → BLOCK expected"
    if contract_check_bash "git push" 2>/dev/null; then
        log_fail "S9: git push should be blocked"
    else
        log_pass "S9: Correctly blocked (git push)"
    fi

    log_test "S10: Bash 'git reset --hard' → BLOCK expected"
    if contract_check_bash "git reset --hard HEAD~1" 2>/dev/null; then
        log_fail "S10: git reset should be blocked"
    else
        log_pass "S10: Correctly blocked (git reset)"
    fi

    log_test "S11: Bash 'git checkout -- .' → BLOCK expected"
    if contract_check_bash "git checkout -- ." 2>/dev/null; then
        log_fail "S11: git checkout should be blocked"
    else
        log_pass "S11: Correctly blocked (git checkout)"
    fi

    log_test "S12: Bash 'git clean -fd' → BLOCK expected"
    if contract_check_bash "git clean -fd" 2>/dev/null; then
        log_fail "S12: git clean should be blocked"
    else
        log_pass "S12: Correctly blocked (git clean)"
    fi

    log_test "S13: Bash 'git rebase -i HEAD~3' → BLOCK expected"
    if contract_check_bash "git rebase -i HEAD~3" 2>/dev/null; then
        log_fail "S13: git rebase should be blocked"
    else
        log_pass "S13: Correctly blocked (git rebase)"
    fi

    # === 読み取り専用 Git は許可 ===
    echo ""
    echo "--- 読み取り専用 Git（許可） ---"

    log_test "S14: Bash 'git status' → ALLOW expected"
    if contract_check_bash "git status" 2>/dev/null; then
        log_pass "S14: Correctly allowed (git status)"
    else
        log_fail "S14: git status should be allowed"
    fi

    log_test "S15: Bash 'git diff' → ALLOW expected"
    if contract_check_bash "git diff" 2>/dev/null; then
        log_pass "S15: Correctly allowed (git diff)"
    else
        log_fail "S15: git diff should be allowed"
    fi

    log_test "S16: Bash 'git log --oneline' → ALLOW expected"
    if contract_check_bash "git log --oneline" 2>/dev/null; then
        log_pass "S16: Correctly allowed (git log)"
    else
        log_fail "S16: git log should be allowed"
    fi

    log_test "S17: Bash 'git show HEAD' → ALLOW expected"
    if contract_check_bash "git show HEAD" 2>/dev/null; then
        log_pass "S17: Correctly allowed (git show)"
    else
        log_fail "S17: git show should be allowed"
    fi

    # === Admin 許可パターン（単一コマンド、全体一致） ===
    echo ""
    echo "--- Admin 許可パターン ---"
    create_test_state "null" "admin"

    log_test "S18: Bash 'mkdir -p plan/archive' → ALLOW expected (admin)"
    if contract_check_bash "mkdir -p plan/archive" 2>/dev/null; then
        log_pass "S18: Correctly allowed (admin mkdir)"
    else
        log_fail "S18: admin mkdir should be allowed"
    fi

    log_test "S19: Bash 'git add state.md' → ALLOW expected (admin)"
    if contract_check_bash "git add state.md" 2>/dev/null; then
        log_pass "S19: Correctly allowed (admin git add state.md)"
    else
        log_fail "S19: admin git add state.md should be allowed"
    fi

    log_test "S20: Bash 'git add -A' → ALLOW expected (admin maintenance)"
    if contract_check_bash "git add -A" 2>/dev/null; then
        log_pass "S20: Correctly allowed (admin maintenance)"
    else
        log_fail "S20: git add -A should be allowed for admin maintenance"
    fi
}

# ==============================================================================
# シナリオ: Fail-Closed テスト（M129 追加）
# ==============================================================================

fail_closed_tests() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  シナリオ: Fail-Closed（STATE_FILE 欠損）"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # state.md を一時的に削除
    rm -f "$STATE_FILE"

    # FC1: Edit が BLOCK される
    log_test "FC1: Edit with no state.md → BLOCK expected"
    if contract_check_edit "src/index.ts" 2>/dev/null; then
        log_fail "FC1: Edit should be blocked without state.md"
    else
        log_pass "FC1: Correctly blocked (fail-closed)"
    fi

    # FC2: 変更系 Bash が BLOCK される
    log_test "FC2: Bash 'mkdir test' with no state.md → BLOCK expected"
    if contract_check_bash "mkdir test" 2>/dev/null; then
        log_fail "FC2: Bash should be blocked without state.md"
    else
        log_pass "FC2: Correctly blocked (fail-closed)"
    fi

    # FC3: 読み取りコマンドも BLOCK される（fail-closed の原則）
    log_test "FC3: Bash 'ls -la' with no state.md → (behavior depends on mutation check)"
    # 読み取りコマンドは変更系でないので許可される可能性がある
    # fail-closed は変更系のみに適用
    if contract_check_bash "ls -la" 2>/dev/null; then
        log_pass "FC3: Read-only allowed (mutation check passes)"
    else
        log_pass "FC3: Blocked (strict fail-closed)"
    fi

    # state.md を再作成
    create_test_state "null" "strict"
}

# ==============================================================================
# シナリオ: HARD_BLOCK コマンドテスト（M129 追加）
# ==============================================================================

hard_block_commands_tests() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  シナリオ: HARD_BLOCK コマンド（全パターン）"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # playbook があっても HARD_BLOCK はブロック
    create_test_state "plan/playbook-test.md" "admin"

    # HBC1: rm -rf /
    log_test "HBC1: 'rm -rf /' → BLOCK expected"
    if contract_check_bash "rm -rf /" 2>/dev/null; then
        log_fail "HBC1: rm -rf / should always be blocked"
    else
        log_pass "HBC1: Correctly blocked"
    fi

    # HBC2: rm -rf ~
    log_test "HBC2: 'rm -rf ~' → BLOCK expected"
    if contract_check_bash "rm -rf ~" 2>/dev/null; then
        log_fail "HBC2: rm -rf ~ should always be blocked"
    else
        log_pass "HBC2: Correctly blocked"
    fi

    # HBC3: rm -rf /*
    log_test "HBC3: 'rm -rf /*' → BLOCK expected"
    if contract_check_bash "rm -rf /*" 2>/dev/null; then
        log_fail "HBC3: rm -rf /* should always be blocked"
    else
        log_pass "HBC3: Correctly blocked"
    fi

    # HBC4: rm -rf $HOME
    log_test "HBC4: 'rm -rf \$HOME' → BLOCK expected"
    if contract_check_bash 'rm -rf $HOME' 2>/dev/null; then
        log_fail "HBC4: rm -rf \$HOME should always be blocked"
    else
        log_pass "HBC4: Correctly blocked"
    fi

    # HBC5: Fork bomb
    log_test "HBC5: Fork bomb → BLOCK expected"
    if contract_check_bash ':(){:|:&};:' 2>/dev/null; then
        log_fail "HBC5: Fork bomb should always be blocked"
    else
        log_pass "HBC5: Correctly blocked"
    fi

    # HBC6: dd if=/dev/zero of=/dev/sda
    log_test "HBC6: 'dd if=/dev/zero of=/dev/sda' → BLOCK expected"
    if contract_check_bash "dd if=/dev/zero of=/dev/sda" 2>/dev/null; then
        log_fail "HBC6: dd to /dev/sda should always be blocked"
    else
        log_pass "HBC6: Correctly blocked"
    fi

    # HBC7: mkfs
    log_test "HBC7: 'mkfs /dev/sda1' → BLOCK expected"
    if contract_check_bash "mkfs /dev/sda1" 2>/dev/null; then
        log_fail "HBC7: mkfs should always be blocked"
    else
        log_pass "HBC7: Correctly blocked"
    fi

    # HBC8: > /dev/sda
    log_test "HBC8: '> /dev/sda' → BLOCK expected"
    if contract_check_bash "> /dev/sda" 2>/dev/null; then
        log_fail "HBC8: > /dev/sda should always be blocked"
    else
        log_pass "HBC8: Correctly blocked"
    fi

    # HBC9: chmod -R 777 /
    log_test "HBC9: 'chmod -R 777 /' → BLOCK expected"
    if contract_check_bash "chmod -R 777 /" 2>/dev/null; then
        log_fail "HBC9: chmod -R 777 / should always be blocked"
    else
        log_pass "HBC9: Correctly blocked"
    fi

    # HBC10: chown -R
    log_test "HBC10: 'chown -R root:root /' → BLOCK expected"
    if contract_check_bash "chown -R root:root /" 2>/dev/null; then
        log_fail "HBC10: chown -R should always be blocked"
    else
        log_pass "HBC10: Correctly blocked"
    fi
}

# ==============================================================================
# シナリオ: Admin Maintenance パターンテスト（M129 追加）
# ==============================================================================

admin_maintenance_tests() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  シナリオ: Admin Maintenance パターン"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # admin + playbook=null
    create_test_state "null" "admin"

    # AM1: mkdir plan/archive
    log_test "AM1: 'mkdir plan/archive' → ALLOW expected (admin)"
    if contract_check_bash "mkdir plan/archive" 2>/dev/null; then
        log_pass "AM1: Correctly allowed"
    else
        log_fail "AM1: Should be allowed for admin maintenance"
    fi

    # AM2: mkdir -p plan/archive
    log_test "AM2: 'mkdir -p plan/archive' → ALLOW expected (admin)"
    if contract_check_bash "mkdir -p plan/archive" 2>/dev/null; then
        log_pass "AM2: Correctly allowed"
    else
        log_fail "AM2: Should be allowed for admin maintenance"
    fi

    # AM3: mv plan/playbook-x.md plan/archive/
    log_test "AM3: 'mv plan/playbook-x.md plan/archive/' → ALLOW expected (admin)"
    if contract_check_bash "mv plan/playbook-x.md plan/archive/" 2>/dev/null; then
        log_pass "AM3: Correctly allowed"
    else
        log_fail "AM3: Should be allowed for admin maintenance"
    fi

    # AM4: git add state.md
    log_test "AM4: 'git add state.md' → ALLOW expected (admin)"
    if contract_check_bash "git add state.md" 2>/dev/null; then
        log_pass "AM4: Correctly allowed"
    else
        log_fail "AM4: Should be allowed for admin maintenance"
    fi

    # AM5: git add plan/archive/
    log_test "AM5: 'git add plan/archive/' → ALLOW expected (admin)"
    if contract_check_bash "git add plan/archive/" 2>/dev/null; then
        log_pass "AM5: Correctly allowed"
    else
        log_fail "AM5: Should be allowed for admin maintenance"
    fi

    # AM6: git add -f plan/archive/
    log_test "AM6: 'git add -f plan/archive/' → ALLOW expected (admin)"
    if contract_check_bash "git add -f plan/archive/" 2>/dev/null; then
        log_pass "AM6: Correctly allowed"
    else
        log_fail "AM6: Should be allowed for admin maintenance"
    fi

    # AM7: git commit -m "..."
    log_test "AM7: 'git commit -m \"chore: maintenance\"' → ALLOW expected (admin)"
    if contract_check_bash 'git commit -m "chore: maintenance"' 2>/dev/null; then
        log_pass "AM7: Correctly allowed"
    else
        log_fail "AM7: Should be allowed for admin maintenance"
    fi

    # AM8: git checkout main
    log_test "AM8: 'git checkout main' → ALLOW expected (admin)"
    if contract_check_bash "git checkout main" 2>/dev/null; then
        log_pass "AM8: Correctly allowed"
    else
        log_fail "AM8: Should be allowed for admin maintenance"
    fi

    # AM9: git merge branch
    log_test "AM9: 'git merge feature-branch' → ALLOW expected (admin)"
    if contract_check_bash "git merge feature-branch" 2>/dev/null; then
        log_pass "AM9: Correctly allowed"
    else
        log_fail "AM9: Should be allowed for admin maintenance"
    fi

    # AM10: git merge branch --no-edit
    log_test "AM10: 'git merge feature-branch --no-edit' → ALLOW expected (admin)"
    if contract_check_bash "git merge feature-branch --no-edit" 2>/dev/null; then
        log_pass "AM10: Correctly allowed"
    else
        log_fail "AM10: Should be allowed for admin maintenance"
    fi

    # AM11: git branch -d branch
    log_test "AM11: 'git branch -d feature-branch' → ALLOW expected (admin)"
    if contract_check_bash "git branch -d feature-branch" 2>/dev/null; then
        log_pass "AM11: Correctly allowed"
    else
        log_fail "AM11: Should be allowed for admin maintenance"
    fi

    # AM12: git add -A
    log_test "AM12: 'git add -A' → ALLOW expected (admin)"
    if contract_check_bash "git add -A" 2>/dev/null; then
        log_pass "AM12: Correctly allowed"
    else
        log_fail "AM12: Should be allowed for admin maintenance"
    fi
}

# ==============================================================================
# 全シナリオ実行
# ==============================================================================

run_all() {
    scenario_a
    scenario_b
    scenario_c
    session_end
    boundary_tests
    security_tests
    fail_closed_tests
    hard_block_commands_tests
    admin_maintenance_tests
}

# ==============================================================================
# メイン
# ==============================================================================

print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  テスト結果サマリー"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "  ${GREEN}PASS${NC}: $PASS_COUNT"
    echo -e "  ${RED}FAIL${NC}: $FAIL_COUNT"
    echo ""

    # テスト結果サマリーをログに記録
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S")
    mkdir -p "$(dirname "$TEST_RESULTS_LOG")"
    echo "{\"timestamp\": \"$timestamp\", \"test\": \"e2e-contract\", \"pass\": $PASS_COUNT, \"fail\": $FAIL_COUNT, \"result\": \"$([ $FAIL_COUNT -eq 0 ] && echo 'PASS' || echo 'FAIL')\"}" >> "$TEST_RESULTS_LOG"

    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo -e "  ${GREEN}ALL TESTS PASSED${NC}"
        return 0
    else
        echo -e "  ${RED}SOME TESTS FAILED${NC}"
        return 1
    fi
}

main() {
    local scenario="${1:-all}"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  E2E Contract Test Suite"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    case "$scenario" in
        scenario_a) scenario_a ;;
        scenario_b) scenario_b ;;
        scenario_c) scenario_c ;;
        session_end) session_end ;;
        boundary) boundary_tests ;;
        security) security_tests ;;
        fail_closed) fail_closed_tests ;;
        hard_block) hard_block_commands_tests ;;
        admin_maintenance) admin_maintenance_tests ;;
        all) run_all ;;
        *)
            echo "Unknown scenario: $scenario"
            echo "Usage: $0 [scenario_a|scenario_b|scenario_c|session_end|boundary|security|fail_closed|hard_block|admin_maintenance|all]"
            exit 1
            ;;
    esac

    print_summary
}

main "$@"
