#!/usr/bin/env bash
# find-unused.sh - 未使用ファイルの検出
#
# 使い方:
#   bash scripts/find-unused.sh          # レポート生成
#   bash scripts/find-unused.sh --delete # 未登録 hooks を削除
#
# 参照の定義:
#   - .claude/settings.json に登録されている
#   - governance/core-manifest.yaml の core に含まれている

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SETTINGS=".claude/settings.json"
MANIFEST="governance/core-manifest.yaml"
HOOK_DIR=".claude/hooks"

DELETE_MODE=false
[[ "${1:-}" == "--delete" ]] && DELETE_MODE=true

echo "========================================"
echo "  Unused Files Report"
echo "========================================"
echo ""
echo "Root: $ROOT"
echo "Mode: $([ "$DELETE_MODE" = true ] && echo 'DELETE' || echo 'REPORT')"
echo ""

# 登録済み hooks を取得
get_registered_hooks() {
    if [[ -f "$SETTINGS" ]]; then
        jq -r '.. | .command? // empty' "$SETTINGS" 2>/dev/null \
            | grep "\.sh" \
            | xargs -n1 basename 2>/dev/null \
            | sort -u
    fi
}

# 全 hooks を取得
get_all_hooks() {
    find "$HOOK_DIR" -maxdepth 1 -type f -name "*.sh" -exec basename {} \; 2>/dev/null | sort
}

echo "=== Hooks Analysis ==="
echo ""

all_hooks=($(get_all_hooks))
registered_hooks=($(get_registered_hooks))

echo "All hooks: ${#all_hooks[@]}"
echo "Registered: ${#registered_hooks[@]}"
echo ""

# 未登録 hooks を検出
echo "--- Unregistered hooks (delete candidates) ---"
unregistered=()
for hook in "${all_hooks[@]}"; do
    if ! printf '%s\n' "${registered_hooks[@]}" | grep -qx "$hook"; then
        unregistered+=("$hook")
        echo "  - $hook"
    fi
done
echo ""
echo "Total unregistered: ${#unregistered[@]}"
echo ""

if [[ "$DELETE_MODE" == "true" && ${#unregistered[@]} -gt 0 ]]; then
    echo "--- Deleting unregistered hooks ---"
    for hook in "${unregistered[@]}"; do
        path="$HOOK_DIR/$hook"
        if [[ -f "$path" ]]; then
            rm "$path"
            echo "  Deleted: $path"
        fi
    done
    echo ""
    echo "Deletion complete. Run 'git status' to see changes."
fi

echo ""
echo "=== Summary ==="
echo "  Hooks: ${#all_hooks[@]} total, ${#registered_hooks[@]} registered, ${#unregistered[@]} unregistered"
echo ""
echo "========================================"
