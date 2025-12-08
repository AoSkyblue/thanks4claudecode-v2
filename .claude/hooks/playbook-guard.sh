#!/bin/bash
# playbook-guard.sh - prompt_type=TASK AND playbook=null で作業をブロック
#
# 目的: playbook なしでの作業開始を構造的に防止
# トリガー: PreToolUse(Edit), PreToolUse(Write)
#
# 動的分類対応:
#   prompt_type=TASK: playbook 必須（ブロック）
#   prompt_type=CHAT/QUESTION: スキップ（playbook 不要）
#   prompt_type=META: スキップ（plan-guard で処理）
#
# 注意: このスクリプトは matcher: "Edit" と "Write" でのみ登録すること
#       matcher: "*" で登録すると stdin を消費し、後続の Hook に影響する

set -euo pipefail

STATE_FILE="${STATE_FILE:-state.md}"

# state.md が存在しない場合はパス
if [[ ! -f "$STATE_FILE" ]]; then
    exit 0
fi

# stdin から JSON を読み込む
INPUT=$(cat)

# jq がない場合はスキップ
if ! command -v jq &> /dev/null; then
    exit 0
fi

# state.md への編集は常に許可（デッドロック回避）
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
if [[ "$FILE_PATH" == *"state.md" ]]; then
    exit 0
fi

# prompt_type を取得（動的分類）
PROMPT_TYPE=$(grep -A6 "^## focus" "$STATE_FILE" | grep "^prompt_type:" | head -1 | sed 's/prompt_type: *//' | sed 's/ *#.*//' | tr -d ' ')

# prompt_type が TASK 以外ならスキップ（CHAT/QUESTION/META は playbook 不要）
if [[ "$PROMPT_TYPE" != "TASK" && "$PROMPT_TYPE" != "null" && -n "$PROMPT_TYPE" ]]; then
    exit 0
fi

# session を取得（yaml ブロック対応）- 後方互換性のため残す
SESSION=$(grep -A6 "^## focus" "$STATE_FILE" | grep "^session:" | head -1 | sed 's/session: *//' | sed 's/ *#.*//' | tr -d ' ')

# session=discussion ならスキップ（空の場合も）
if [[ "$SESSION" != "task" ]]; then
    exit 0
fi

# focus.current を取得
FOCUS=$(grep -A6 "^## focus" "$STATE_FILE" | grep "^current:" | head -1 | sed 's/current: *//' | sed 's/ *#.*//' | tr -d ' ')

# active_playbooks から現在の focus の playbook を取得
PLAYBOOK=$(grep -A8 "^## active_playbooks" "$STATE_FILE" | grep "^${FOCUS}:" | head -1 | sed "s/${FOCUS}: *//" | sed 's/ *#.*//' | tr -d ' ')

# playbook が null または空なら ブロック
if [[ -z "$PLAYBOOK" || "$PLAYBOOK" == "null" ]]; then
    cat >&2 << 'EOF'
========================================
  ⛔ playbook 必須
========================================

  session=task では playbook が必要です。

  対処法（いずれかを実行）:

    [推奨] pm エージェントを呼び出す:
      Task(subagent_type='pm', prompt='playbook を作成してください')

    または /playbook-init を実行:
      /playbook-init

    または session を discussion に変更:
      Edit state.md: session: discussion

  現在の状態:
EOF
    echo "    focus: $FOCUS" >&2
    echo "    session: $SESSION" >&2
    echo "    playbook: null" >&2
    echo "" >&2
    echo "========================================" >&2
    exit 2
fi

# playbook があればパス
exit 0
