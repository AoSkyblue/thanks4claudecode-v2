#!/bin/bash
# test-done-criteria.sh - done_criteria テストを実行
#
# 用途: /test コマンドから呼び出される
# 引数:
#   $1: 空（互換性のため）
#   $2: (オプション) 特定のテスト名フィルタ

set -euo pipefail

TEST_DIR=".claude/tests"

# テストディレクトリが存在しない場合
if [[ ! -d "$TEST_DIR" ]]; then
    echo "[FAIL] Test directory not found: $TEST_DIR" >&2
    exit 1
fi

# 引数処理（/test からは "" $1 形式で渡される）
TARGET="${2:-${1:-}}"

# テストファイルを収集
if [[ -n "$TARGET" ]]; then
    mapfile -t TESTS < <(find "$TEST_DIR" -name "*.sh" -type f 2>/dev/null | grep -i "$TARGET" || true)
else
    mapfile -t TESTS < <(find "$TEST_DIR" -name "*.sh" -type f 2>/dev/null || true)
fi

# テストが見つからない場合
if [[ "${#TESTS[@]}" -eq 0 ]]; then
    echo "[INFO] No tests found (filter='$TARGET')"
    echo "[INFO] Available tests in $TEST_DIR:"
    find "$TEST_DIR" -name "*.sh" -type f 2>/dev/null | sed 's/^/  - /' || echo "  (none)"
    exit 1
fi

# テスト実行
PASS=0
FAIL=0
SKIP=0

echo "========================================"
echo "  done_criteria Tests"
echo "========================================"
echo ""
echo "Test directory: $TEST_DIR"
echo "Filter: ${TARGET:-'(all)'}"
echo "Tests found: ${#TESTS[@]}"
echo ""

for test_file in "${TESTS[@]}"; do
    test_name=$(basename "$test_file" .sh)
    echo "--- Running: $test_name"
    
    # テストが実行可能か確認
    if [[ ! -x "$test_file" ]]; then
        echo "[SKIP] Not executable: $test_file"
        SKIP=$((SKIP + 1))
        continue
    fi
    
    # テスト実行
    if bash "$test_file"; then
        echo "[PASS] $test_name"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] $test_name"
        FAIL=$((FAIL + 1))
    fi
    echo ""
done

# 結果サマリー
echo "========================================"
echo "  Results"
echo "========================================"
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "  SKIP: $SKIP"
echo "  Total: ${#TESTS[@]}"
echo "========================================"

# 失敗があれば exit 1
if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi

exit 0
