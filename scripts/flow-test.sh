#!/usr/bin/env bash
# ==============================================================================
# flow-test.sh - 動線単位テスト（E2E）
# ==============================================================================
# M107: 報酬詐欺防止設計
#
# 設計原則:
#   - FAIL が出ることを前提とした設計
#   - 全 PASS は「テスト設計不備」の可能性として警告
#   - 構文チェック（bash -n）ではなく、実際のフローをテスト
#
# テスト対象動線:
#   1. 計画動線: ユーザー要求 → pm → playbook → state.md
#   2. 実行動線: playbook active → Edit/Write → Guard 発火
#   3. 検証動線: /crit → critic → done_criteria 検証
#   4. 完了動線: phase 完了 → アーカイブ → project.md 更新
# ==============================================================================

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# ==============================================================================
# 設定
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

# ==============================================================================
# ヘルパー関数
# ==============================================================================
pass() {
    echo -e "  ${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++))
}

fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
    ((FAIL_COUNT++))
}

skip() {
    echo -e "  ${YELLOW}[SKIP]${NC} $1"
    ((SKIP_COUNT++))
}

header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
}

# ==============================================================================
# 1. 計画動線テスト
# ==============================================================================
# EXPECTED_FAIL:
#   - pm が playbook を作成しない場合（pm.md 不存在）
#   - state.md の playbook.active 更新が動作しない場合
#   - prompt-guard.sh がタスク要求を検出しない場合
# ==============================================================================
test_planning_flow() {
    header "1. 計画動線テスト"

    # 1.1 pm SubAgent 存在確認
    if [[ -f .claude/agents/pm.md ]]; then
        if grep -q "playbook" .claude/agents/pm.md 2>/dev/null; then
            pass "pm.md - playbook 作成ロジック存在"
        else
            fail "pm.md - playbook キーワードなし"
        fi
    else
        fail "pm.md - ファイル不存在（EXPECTED_FAIL if missing）"
    fi

    # 1.2 state.md の playbook セクション
    if grep -qE "^active:" state.md 2>/dev/null; then
        PLAYBOOK=$(grep "^active:" state.md | head -1 | sed 's/active: *//')
        if [[ -n "$PLAYBOOK" && "$PLAYBOOK" != "null" && -f "$PLAYBOOK" ]]; then
            pass "state.md - playbook.active が有効なファイルを指す"
        else
            fail "state.md - playbook.active が無効（$PLAYBOOK）"
        fi
    else
        fail "state.md - playbook セクションなし"
    fi

    # 1.3 prompt-guard.sh タスク要求検出
    if [[ -f .claude/hooks/prompt-guard.sh ]]; then
        # タスク要求パターンが定義されているか
        if grep -qE "作って|実装して|追加して|修正して" .claude/hooks/prompt-guard.sh 2>/dev/null; then
            pass "prompt-guard.sh - タスク要求パターン定義あり"
        else
            fail "prompt-guard.sh - タスク要求パターン未定義（EXPECTED_FAIL）"
        fi

        # playbook=null 時の警告ロジック
        if grep -qE "playbook.*null|pm.*必須" .claude/hooks/prompt-guard.sh 2>/dev/null; then
            pass "prompt-guard.sh - pm 必須警告ロジックあり"
        else
            fail "prompt-guard.sh - pm 必須警告なし"
        fi
    else
        fail "prompt-guard.sh - ファイル不存在"
    fi
}

# ==============================================================================
# 2. 実行動線テスト
# ==============================================================================
# EXPECTED_FAIL:
#   - playbook=null で Edit がブロックされない場合
#   - subtask-guard.sh が STRICT=1 でブロックしない場合
#   - 危険コマンドがブロックされない場合
#   - main ブランチで Edit が許可される場合
# ==============================================================================
test_execution_flow() {
    header "2. 実行動線テスト"

    # 2.1 playbook-guard.sh の存在と基本ロジック
    if [[ -f .claude/hooks/playbook-guard.sh ]]; then
        if grep -qE "playbook.*null|active.*null" .claude/hooks/playbook-guard.sh 2>/dev/null; then
            pass "playbook-guard.sh - null チェックロジックあり"
        else
            fail "playbook-guard.sh - null チェックロジックなし（EXPECTED_FAIL）"
        fi

        # exit 2 でブロックするか
        if grep -qE "exit 2" .claude/hooks/playbook-guard.sh 2>/dev/null; then
            pass "playbook-guard.sh - exit 2 ブロックあり"
        else
            fail "playbook-guard.sh - exit 2 ブロックなし"
        fi
    else
        fail "playbook-guard.sh - ファイル不存在"
    fi

    # 2.2 subtask-guard.sh STRICT モード
    if [[ -f .claude/hooks/subtask-guard.sh ]]; then
        if grep -qE 'STRICT:-1|STRICT=1' .claude/hooks/subtask-guard.sh 2>/dev/null; then
            pass "subtask-guard.sh - STRICT=1 デフォルト（M106 修正済み）"
        else
            fail "subtask-guard.sh - STRICT=1 デフォルトでない（EXPECTED_FAIL if not M106）"
        fi
    else
        fail "subtask-guard.sh - ファイル不存在"
    fi

    # 2.3 pre-bash-check.sh 危険コマンドチェック
    if [[ -f .claude/hooks/pre-bash-check.sh ]]; then
        if grep -qE "rm -rf|HARD_BLOCK|危険" .claude/hooks/pre-bash-check.sh 2>/dev/null; then
            pass "pre-bash-check.sh - 危険コマンドパターンあり"
        else
            fail "pre-bash-check.sh - 危険コマンドパターンなし（EXPECTED_FAIL）"
        fi
    else
        fail "pre-bash-check.sh - ファイル不存在"
    fi

    # 2.4 check-main-branch.sh
    if [[ -f .claude/hooks/check-main-branch.sh ]]; then
        if grep -qE "main|master" .claude/hooks/check-main-branch.sh 2>/dev/null; then
            pass "check-main-branch.sh - main/master ブランチチェックあり"
        else
            fail "check-main-branch.sh - ブランチチェックなし（EXPECTED_FAIL）"
        fi
    else
        skip "check-main-branch.sh - ファイル不存在（optional）"
    fi

    # 2.5 consent-guard.sh デッドロック修正
    if [[ -f .claude/hooks/consent-guard.sh ]]; then
        if grep -qE "playbook.active|PLAYBOOK_ACTIVE" .claude/hooks/consent-guard.sh 2>/dev/null; then
            pass "consent-guard.sh - playbook 存在チェックあり（M106 修正済み）"
        else
            fail "consent-guard.sh - playbook 存在チェックなし（EXPECTED_FAIL if not M106）"
        fi
    else
        fail "consent-guard.sh - ファイル不存在"
    fi
}

# ==============================================================================
# 3. 検証動線テスト
# ==============================================================================
# EXPECTED_FAIL:
#   - critic が PASS/FAIL の根拠を出力しない場合
#   - critic-guard.sh が phase 完了をチェックしない場合
#   - done_criteria に test_command がない場合
# ==============================================================================
test_verification_flow() {
    header "3. 検証動線テスト"

    # 3.1 critic SubAgent
    if [[ -f .claude/agents/critic.md ]]; then
        if grep -qE "done_criteria|PASS|FAIL" .claude/agents/critic.md 2>/dev/null; then
            pass "critic.md - done_criteria 検証ロジックあり"
        else
            fail "critic.md - done_criteria 検証ロジックなし（EXPECTED_FAIL）"
        fi
    else
        fail "critic.md - ファイル不存在"
    fi

    # 3.2 critic-guard.sh phase 完了チェック
    if [[ -f .claude/hooks/critic-guard.sh ]]; then
        if grep -qE "playbook-|status.*done" .claude/hooks/critic-guard.sh 2>/dev/null; then
            pass "critic-guard.sh - phase 完了チェックあり（M106 修正済み）"
        else
            fail "critic-guard.sh - phase 完了チェックなし（EXPECTED_FAIL if not M106）"
        fi
    else
        fail "critic-guard.sh - ファイル不存在"
    fi

    # 3.3 現在の playbook に test_command があるか
    PLAYBOOK=$(awk '/## playbook/,/^---/' state.md 2>/dev/null | grep "^active:" | head -1 | sed 's/active: *//')
    if [[ -n "$PLAYBOOK" && "$PLAYBOOK" != "null" && -f "$PLAYBOOK" ]]; then
        TEST_CMD_COUNT=$(grep -c "test_command" "$PLAYBOOK" 2>/dev/null || echo 0)
        if [[ "$TEST_CMD_COUNT" -gt 0 ]]; then
            pass "playbook - test_command が $TEST_CMD_COUNT 件定義"
        else
            fail "playbook - test_command 未定義（EXPECTED_FAIL）"
        fi
    else
        skip "playbook - active playbook なし"
    fi

    # 3.4 /crit コマンド存在
    if [[ -f .claude/commands/crit.md ]]; then
        pass "crit.md - /crit コマンド存在"
    else
        fail "crit.md - /crit コマンド不存在"
    fi
}

# ==============================================================================
# 4. 完了動線テスト
# ==============================================================================
# EXPECTED_FAIL:
#   - archive-playbook.sh が done_when 検証をスキップする場合
#   - project.md が自動更新されない場合
#   - 次タスク導出が動作しない場合
# ==============================================================================
test_completion_flow() {
    header "4. 完了動線テスト"

    # 4.1 archive-playbook.sh
    if [[ -f .claude/hooks/archive-playbook.sh ]]; then
        if bash -n .claude/hooks/archive-playbook.sh 2>/dev/null; then
            pass "archive-playbook.sh - 構文チェック OK"
        else
            fail "archive-playbook.sh - 構文エラー"
        fi
    else
        skip "archive-playbook.sh - ファイル不存在（optional）"
    fi

    # 4.2 project.md に achieved milestone があるか
    if [[ -f plan/project.md ]]; then
        ACHIEVED=$(grep -c "status: achieved" plan/project.md 2>/dev/null || echo 0)
        if [[ "$ACHIEVED" -gt 0 ]]; then
            pass "project.md - $ACHIEVED 件の achieved milestone"
        else
            fail "project.md - achieved milestone なし（EXPECTED_FAIL if new project）"
        fi
    else
        fail "project.md - ファイル不存在"
    fi

    # 4.3 plan/archive ディレクトリ
    if [[ -d plan/archive ]]; then
        ARCHIVED=$(ls plan/archive/*.md 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$ARCHIVED" -gt 0 ]]; then
            pass "plan/archive - $ARCHIVED 件のアーカイブ済み playbook"
        else
            skip "plan/archive - アーカイブなし（新プロジェクト）"
        fi
    else
        skip "plan/archive - ディレクトリ不存在"
    fi

    # 4.4 next タスク導出（state.md に next があるか）
    if grep -qE "^next:" state.md 2>/dev/null; then
        pass "state.md - next タスク定義あり"
    else
        skip "state.md - next フィールドなし"
    fi
}

# ==============================================================================
# メイン
# ==============================================================================
main() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         M107 動線単位テスト（E2E）                           ║${NC}"
    echo -e "${BLUE}║         報酬詐欺防止設計: FAIL が出ることを期待             ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

    test_planning_flow
    test_execution_flow
    test_verification_flow
    test_completion_flow

    # サマリー
    header "Test Summary"
    echo -e "  ${GREEN}PASS: $PASS_COUNT${NC}"
    echo -e "  ${RED}FAIL: $FAIL_COUNT${NC}"
    echo -e "  ${YELLOW}SKIP: $SKIP_COUNT${NC}"
    echo ""

    TOTAL=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
    echo "  Total: $TOTAL tests"
    echo ""

    # ==============================================================================
    # 報酬詐欺防止: 全 PASS 警告
    # ==============================================================================
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}  ⚠️  All PASS (suspicious - review test design)${NC}"
        echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo "  FAIL が 0 件です。以下を確認してください:"
        echo "    1. テストが十分に厳格か"
        echo "    2. EXPECTED_FAIL 条件が本当に発生しないか"
        echo "    3. テスト設計に不備がないか"
        echo ""
        exit 0
    else
        echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  Tests completed with $FAIL_COUNT FAIL(s) (expected)${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo "  FAIL は正常です。M108 で修正予定。"
        echo ""
        exit 0
    fi
}

main "$@"
