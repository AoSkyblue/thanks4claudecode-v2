#!/bin/bash
# ==============================================================================
# subtask-guard.sh - subtask の 3 検証を強制
# ==============================================================================
# 目的: subtask.status = done 変更時に 3 つの検証を実行
# トリガー: PreToolUse(Edit)
#
# 【単一責任原則 (SRP)】
# このスクリプトは「subtask 検証」のみを担当
#
# 3 つの検証:
#   1. technical: 技術的に正しく動作するか
#   2. consistency: 他のコンポーネントと整合性があるか
#   3. completeness: 必要な変更が全て完了しているか
#
# M056: final_tasks の status: done 変更は許可（スキップ）
# ==============================================================================

set -euo pipefail

# 入力 JSON を読み取り
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')

# Edit ツール以外はパス
if [[ "$TOOL_NAME" != "Edit" ]]; then
    exit 0
fi

# playbook ファイルへの編集のみチェック
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
if [[ "$FILE_PATH" != *"playbook-"* ]]; then
    exit 0
fi

# status: done への変更をチェック
OLD_STRING=$(echo "$TOOL_INPUT" | jq -r '.old_string // empty')
NEW_STRING=$(echo "$TOOL_INPUT" | jq -r '.new_string // empty')

# ==============================================================================
# M056: final_tasks セクションの status: done 変更は許可（スキップ）
# ==============================================================================
# final_tasks は subtasks とは異なり、単純なチェックリストなので
# validations は不要。status: done への変更を許可する。
# 判定: old_string に "final_tasks" または "ft1\|ft2\|ft3" が含まれていれば final_tasks
# ==============================================================================
if [[ "$OLD_STRING" == *"final_tasks"* ]] || [[ "$OLD_STRING" == *"- id: ft"* ]]; then
    # final_tasks の status 変更 → 許可（bypass）
    exit 0
fi

# status が変更されていない場合はパス
if [[ "$OLD_STRING" == *"status: pending"* || "$OLD_STRING" == *"status: in_progress"* ]]; then
    if [[ "$NEW_STRING" == *"status: done"* ]]; then
        # subtask の status: done への変更を検出
        # validations が含まれているかチェック
        if [[ "$NEW_STRING" != *"validations:"* ]]; then
            # validations がない場合はブロック
            echo "[subtask-guard] ❌ BLOCKED: status: done への変更には validations が必須です。"
            echo ""
            echo "subtask に以下の 3 検証を追加してください:"
            echo "  validations:"
            echo "    technical: \"test_command の期待結果\""
            echo "    consistency: \"関連ファイルとの整合性\""
            echo "    completeness: \"必要な変更が全て完了\""
            echo ""
            echo "参照: plan/template/playbook-format.md"
            exit 2
        fi

        # validations がある場合は警告のみで許可
        echo "{\"decision\": \"allow\", \"systemMessage\": \"[subtask-guard] ⚠️ Phase を done にする前に、以下の 3 検証を確認してください:\\n\\n1. technical: test_command が PASS を返すか\\n2. consistency: 関連ファイルとの整合性があるか\\n3. completeness: 必要な変更が全て完了しているか\\n\\n critic SubAgent による検証を推奨します。\"}"
        exit 0
    fi
fi

# その他の変更はパス
exit 0
