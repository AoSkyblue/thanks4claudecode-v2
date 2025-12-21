#!/bin/bash
# verify-manifest.sh - 仕様（core-manifest.yaml）と実態の乖離を検出
#
# 目的:
#   - core-manifest.yaml に記載されたコンポーネントが実際に存在するか確認
#   - settings.json に登録されているかも確認
#   - 乖離があればエラーを報告
#
# 使用例:
#   bash scripts/verify-manifest.sh
#
# 終了コード:
#   0: 全て一致
#   1: 乖離あり

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MANIFEST="governance/core-manifest.yaml"
SETTINGS=".claude/settings.json"
HOOKS_DIR=".claude/hooks"

ERRORS=0
WARNINGS=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  verify-manifest.sh - 仕様と実態の検証"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================
# core-manifest.yaml が存在するか確認
# ============================================================
if [ ! -f "$MANIFEST" ]; then
    echo -e "${RED}[ERROR]${NC} $MANIFEST が存在しません"
    exit 1
fi

# ============================================================
# settings.json が存在するか確認
# ============================================================
if [ ! -f "$SETTINGS" ]; then
    echo -e "${RED}[ERROR]${NC} $SETTINGS が存在しません"
    exit 1
fi

# ============================================================
# Hook の検証（testing セクションを除外）
# ============================================================
echo "【Hook の検証】"
echo ""

# core-manifest.yaml から type: hook のコンポーネントを抽出
# 形式: - name: xxx.sh
#       type: hook
# 注: testing セクションと deletion_candidates セクションを除外

# deletion_candidates と testing セクションを除外して Hook を抽出
# 構造: - name: xxx.sh の次の行に type: hook がある
# testing: は scripts/ 配下のテストスクリプト（hooks ではない）
HOOKS=$(grep -B1 "type: hook" "$MANIFEST" | grep "name:" | grep -v "^--$" | sed 's/.*name: *//' | tr -d ' ' | grep '\.sh$' | sort -u)

for HOOK in $HOOKS; do
    # ファイル存在チェック
    if [ -f "$HOOKS_DIR/$HOOK" ]; then
        FILE_STATUS="${GREEN}[EXISTS]${NC}"
    else
        FILE_STATUS="${RED}[MISSING]${NC}"
        ERRORS=$((ERRORS + 1))
    fi

    # settings.json 登録チェック
    if grep -q "$HOOK" "$SETTINGS" 2>/dev/null; then
        SETTINGS_STATUS="${GREEN}[REGISTERED]${NC}"
    else
        SETTINGS_STATUS="${YELLOW}[NOT_REG]${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi

    echo -e "  $HOOK: $FILE_STATUS $SETTINGS_STATUS"
done

echo ""

# ============================================================
# settings.json に登録されているが core-manifest.yaml にない Hook
# ============================================================
echo "【逆引きチェック：settings.json → core-manifest.yaml】"
echo ""

# settings.json から Hook を抽出
REGISTERED_HOOKS=$(grep -oE 'hooks/[a-zA-Z0-9_-]+\.sh' "$SETTINGS" | sed 's|hooks/||' | sort -u)

for HOOK in $REGISTERED_HOOKS; do
    if grep -q "name: $HOOK" "$MANIFEST" 2>/dev/null; then
        echo -e "  $HOOK: ${GREEN}[OK]${NC} manifest に記載あり"
    else
        # deletion_candidates にあるかチェック
        if awk '/^deletion_candidates:/,0' "$MANIFEST" | grep -q "$HOOK" 2>/dev/null; then
            echo -e "  $HOOK: ${YELLOW}[WARN]${NC} deletion_candidates に記載"
        else
            echo -e "  $HOOK: ${RED}[ORPHAN]${NC} manifest に記載なし"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

echo ""

# ============================================================
# 実ファイルとの整合性チェック
# ============================================================
echo "【実ファイル整合性チェック】"
echo ""

# .claude/hooks/ 内の全 .sh ファイル
ACTUAL_HOOKS=$(ls -1 "$HOOKS_DIR"/*.sh 2>/dev/null | xargs -I{} basename {} | sort -u)

for HOOK in $ACTUAL_HOOKS; do
    if grep -q "name: $HOOK" "$MANIFEST" 2>/dev/null; then
        echo -e "  $HOOK: ${GREEN}[OK]${NC} manifest に記載あり"
    else
        # deletion_candidates にあるかチェック
        if awk '/^deletion_candidates:/,0' "$MANIFEST" | grep -q "$HOOK" 2>/dev/null; then
            echo -e "  $HOOK: ${YELLOW}[DELETION]${NC} 削除候補"
        else
            echo -e "  $HOOK: ${YELLOW}[UNLISTED]${NC} manifest 未記載"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

echo ""

# ============================================================
# 結果サマリー
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  検証結果"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} 仕様と実態が完全に一致しています"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}[WARN]${NC} 警告: $WARNINGS 件"
    echo "  → 動作に問題はありませんが、確認を推奨します"
    exit 0
else
    echo -e "${RED}[FAIL]${NC} エラー: $ERRORS 件, 警告: $WARNINGS 件"
    echo "  → 仕様と実態に乖離があります"
    exit 1
fi
