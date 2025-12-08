#!/bin/bash
# prompt-validator.sh - プロンプト分類をトリガー
#
# UserPromptSubmit フックとして実行される。
# 機械的に発火し、Claude に分類を指示する。
# 実際の分類は LLM の自然言語理解に任せる。
#
# 設計思想:
#   - Hook: 発火のみ（キーワード判定しない）
#   - LLM: NLU で分類（自然言語の強みを活かす）
#   - Guard: session を読んで強制（構造的制御）

set -e

# 色定義
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# state.md が存在しない場合はスキップ
if [ ! -f "state.md" ]; then
    exit 0
fi

# 現在の session を取得
CURRENT_SESSION=$(grep -A 2 "^## focus" "state.md" 2>/dev/null | grep "session:" | head -1 | sed 's/.*session:[[:space:]]*//' | sed 's/#.*//' | tr -d ' ' || echo "QUESTION")

# ============================================================
# 出力: Claude への分類指示
# ============================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${CYAN}[SESSION 分類]${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  現在: $CURRENT_SESSION"
echo ""
echo -e "  ${YELLOW}【必須】このプロンプトを分類し state.md を更新せよ${NC}"
echo ""
echo "  TASK: 作業指示（実装、修正、テスト、デプロイ等）"
echo "  CHAT: 雑談・挨拶"
echo "  QUESTION: 質問・確認"
echo "  META: 計画変更・scope 変更"
echo ""
echo "  → state.md の session: 行を更新"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exit 0
