# StateInjection 設計ドキュメント

> **p0: systemMessage に注入する情報とフォーマットの設計**

---

## 1. 現状分析

### prompt-guard.sh の systemMessage 出力方法

```bash
# JSON 形式で stdout に出力すると systemMessage に注入される
cat <<EOF
{
  "systemMessage": "注入したいテキスト"
}
EOF
```

### 現在の問題

| 問題 | 説明 |
|------|------|
| SessionStart は出力のみ | 強制力なし。LLM が無視可能 |
| init-guard はツール使用時のみ | LLM がツールを使わないと発火しない |
| prompt-guard は警告のみ | state/project/playbook の情報を注入していない |

---

## 2. 注入すべき情報

### 必須（Always inject）

| フィールド | 取得元 | 説明 |
|-----------|--------|------|
| focus.current | state.md | 現在作業中のプロジェクト |
| goal.milestone | state.md | 現在の milestone ID |
| goal.phase | state.md | 現在の phase ID |
| goal.done_criteria | state.md | phase の完了条件 |
| playbook.active | state.md | 活動中の playbook パス |

### オプション（Conditional）

| フィールド | 取得元 | 条件 |
|-----------|--------|------|
| project_summary | project.md | project.md が存在する場合 |
| remaining_milestones | project.md | milestone 数をカウント |
| remaining_phases | playbook | phase 数をカウント |
| git_branch | git | 現在のブランチ名 |
| git_status | git | clean/modified/untracked |

---

## 3. systemMessage フォーマット

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📍 State Injection（自動注入）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
focus: {focus.current}
milestone: {goal.milestone}
phase: {goal.phase}
playbook: {playbook.active}
branch: {git_branch}
remaining: {X} phases / {Y} milestones

done_criteria:
  - {criteria_1}
  - {criteria_2}
  - ...

⚠️ この情報は UserPromptSubmit で自動注入されています。
   Read せずに上記の情報を使用できます。
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 4. 実装方針

### prompt-guard.sh の拡張

```bash
# 常に state.md の情報を読み取って systemMessage に注入
# 既存の警告ロジック（報酬詐欺、スコープ外）は維持

# 1. state.md から情報抽出
FOCUS=$(grep -A5 "## focus" state.md | grep "current:" | ...)
MILESTONE=$(grep -A5 "## goal" state.md | grep "milestone:" | ...)
PHASE=$(grep -A5 "## goal" state.md | grep "phase:" | ...)
PLAYBOOK=$(awk '/## playbook/,/^---/' state.md | grep "active:" | ...)
CRITERIA=$(awk '/done_criteria:/,/^```/' state.md | grep "^  -" | ...)

# 2. git 情報
GIT_BRANCH=$(git branch --show-current)
GIT_STATUS=$(git status --porcelain | wc -l)

# 3. systemMessage を構築して出力（常に）
cat <<EOF
{
  "systemMessage": "━━━ State Injection ━━━\\nfocus: $FOCUS\\nmilestone: $MILESTONE\\nphase: $PHASE\\n..."
}
EOF
```

---

## 5. 設計上の考慮事項

### JSON エスケープ

- 改行: `\n` → `\\n`
- ダブルクォート: `"` → `\"`
- バックスラッシュ: `\` → `\\`

### 出力の上限

- systemMessage は簡潔に（500文字以内目標）
- 詳細は Read で取得させる

### /clear 後の動作

- state.md が存在しない場合も考慮
- playbook=null の場合は「playbook: null」と表示

---

## 6. テスト計画

| テスト | 確認内容 |
|--------|----------|
| 通常プロンプト | systemMessage が注入される |
| /clear 後 | playbook=null でも動作 |
| 複数プロンプト | 毎回 systemMessage が更新される |
| JSON エスケープ | 特殊文字を含む done_criteria |

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-13 | p0 設計完了 |
