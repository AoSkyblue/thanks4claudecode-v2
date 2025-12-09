# Phase 6 成果物: 復旧手順の文書化

> **playbook-current-implementation-redesign Phase 6**
>
> 日時: 2025-12-09
> 目的: 「何を失ったら、どのファイルを復旧すればよいか」を明記

---

## 1. 復旧優先順位

```
【最優先】システムが動作しない
  1. settings.json       → 全 Hook が発火しない
  2. session-start.sh    → セッション初期化なし
  3. init-guard.sh       → 必須 Read 強制なし
  4. playbook-guard.sh   → playbook 強制なし

【高優先】重要機能が欠損
  5. critic-guard.sh     → 報酬詐欺防止なし
  6. critic.md           → done_criteria 検証なし
  7. pm.md               → playbook 管理なし
  8. consent-guard.sh    → 誤解釈防止なし
  9. state.md            → 状態管理なし

【中優先】品質保証機能が欠損
  10. check-coherence.sh → 整合性チェックなし
  11. coherence.md       → 整合性修正なし
  12. state-mgr.md       → state.md 自動管理なし

【低優先】補助機能が欠損
  13. その他 Hook / SubAgent / Skill
```

---

## 2. シナリオ別復旧手順

### 2.1 settings.json が破損・削除された場合

**症状**: 全ての Hook が発火しない

**復旧手順**:

```bash
# 方法 1: git から復元
git checkout HEAD -- .claude/settings.json

# 方法 2: 最小構成で再作成
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": ["Edit", "Write", "Task(*)", "Bash(git:*)"]
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/session-start.sh", "timeout": 5000}]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/init-guard.sh", "timeout": 3000}]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {"type": "command", "command": "bash .claude/hooks/playbook-guard.sh", "timeout": 3000},
          {"type": "command", "command": "bash .claude/hooks/critic-guard.sh", "timeout": 3000}
        ]
      },
      {
        "matcher": "Write",
        "hooks": [
          {"type": "command", "command": "bash .claude/hooks/playbook-guard.sh", "timeout": 3000}
        ]
      }
    ]
  }
}
EOF
```

**確認**: 新セッションを開始し、session-start.sh の出力が表示されることを確認

---

### 2.2 .claude/hooks/ が削除された場合

**症状**: Hook ファイルが見つからないエラー

**復旧手順**:

```bash
# 方法 1: git から復元
git checkout HEAD -- .claude/hooks/

# 方法 2: 必須 Hook のみ再作成（最小構成）
mkdir -p .claude/hooks

# session-start.sh（最小版）
cat > .claude/hooks/session-start.sh << 'EOF'
#!/bin/bash
mkdir -p .claude/.session-init
touch .claude/.session-init/pending
echo "セッション開始。state.md を Read してください。"
exit 0
EOF

# init-guard.sh（最小版）
cat > .claude/hooks/init-guard.sh << 'EOF'
#!/bin/bash
PENDING=".claude/.session-init/pending"
[ ! -f "$PENDING" ] && exit 0
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
[ "$TOOL" = "Read" ] && rm -f "$PENDING" && exit 0
echo "state.md を Read してください" >&2
exit 2
EOF

# playbook-guard.sh（最小版）
cat > .claude/hooks/playbook-guard.sh << 'EOF'
#!/bin/bash
[ ! -f "state.md" ] && exit 0
FOCUS=$(grep "current:" state.md | head -1 | sed 's/.*: *//')
PLAYBOOK=$(grep "${FOCUS}:" state.md | grep -v "current" | head -1 | sed 's/.*: *//')
[ -z "$PLAYBOOK" ] || [ "$PLAYBOOK" = "null" ] && echo "playbook 必須" >&2 && exit 2
exit 0
EOF

chmod +x .claude/hooks/*.sh
```

---

### 2.3 .claude/agents/ が削除された場合

**症状**: SubAgent が見つからない

**復旧手順**:

```bash
# 方法 1: git から復元
git checkout HEAD -- .claude/agents/

# 方法 2: 必須 SubAgent のみ再作成
mkdir -p .claude/agents

# critic.md（最小版）
cat > .claude/agents/critic.md << 'EOF'
---
name: critic
description: MUST BE USED before marking any task as done. Evaluates done_criteria with evidence-based judgment.
tools: Read, Grep, Bash
model: haiku
---

done_criteria の各項目について証拠を確認してください。
証拠がない項目は FAIL です。
全項目に証拠があれば PASS を返してください。
EOF

# pm.md（最小版）
cat > .claude/agents/pm.md << 'EOF'
---
name: pm
description: PROACTIVELY manages playbooks and project progress. Creates playbook when missing.
tools: Read, Write, Edit, Grep, Glob
model: haiku
---

playbook がない場合は作成してください。
plan/active/playbook-{task-name}.md に作成します。
EOF
```

---

### 2.4 state.md が破損・削除された場合

**症状**: focus が不明、playbook が特定できない

**復旧手順**:

```bash
# 方法 1: git から復元
git checkout HEAD -- state.md

# 方法 2: 最小構成で再作成
cat > state.md << 'EOF'
# state.md

## focus

```yaml
current: product
```

---

## active_playbooks

```yaml
product: null
```

---

## goal

```yaml
phase: idle
done_criteria: []
```

---

## verification

```yaml
self_complete: false
```
EOF
```

**復旧後**:
1. `git log --oneline` で最新コミットを確認
2. playbook があれば `active_playbooks.product` を更新

---

### 2.5 protected-files.txt が削除された場合

**症状**: 保護ファイルが編集可能になる

**復旧手順**:

```bash
cat > .claude/protected-files.txt << 'EOF'
# BLOCK: 絶対守護（ユーザー許可必須）
CLAUDE.md:BLOCK
.claude/settings.json:BLOCK

# WARN: 警告のみ
state.md:WARN
plan/project.md:WARN
EOF
```

---

### 2.6 .claude/.session-init/ が残っている場合

**症状**: セッション開始時にブロックされる

**復旧手順**:

```bash
rm -rf .claude/.session-init/
```

---

## 3. 復旧スクリプト

### 3.1 全体復旧スクリプト

```bash
#!/bin/bash
# recovery.sh - システム全体の復旧

set -e

echo "=== Claude Code 拡張システム復旧 ==="

# 1. .claude ディレクトリ確認
if [ ! -d ".claude" ]; then
    echo "[ERROR] .claude ディレクトリが存在しません"
    echo "git checkout HEAD -- .claude/"
    exit 1
fi

# 2. settings.json 確認
if [ ! -f ".claude/settings.json" ]; then
    echo "[WARN] settings.json が存在しません"
    echo "git checkout HEAD -- .claude/settings.json"
fi

# 3. 必須 Hook 確認
REQUIRED_HOOKS=(
    "session-start.sh"
    "init-guard.sh"
    "playbook-guard.sh"
    "critic-guard.sh"
)

for hook in "${REQUIRED_HOOKS[@]}"; do
    if [ ! -f ".claude/hooks/$hook" ]; then
        echo "[WARN] $hook が存在しません"
        echo "git checkout HEAD -- .claude/hooks/$hook"
    fi
done

# 4. 必須 SubAgent 確認
REQUIRED_AGENTS=(
    "critic.md"
    "pm.md"
)

for agent in "${REQUIRED_AGENTS[@]}"; do
    if [ ! -f ".claude/agents/$agent" ]; then
        echo "[WARN] $agent が存在しません"
        echo "git checkout HEAD -- .claude/agents/$agent"
    fi
done

# 5. state.md 確認
if [ ! -f "state.md" ]; then
    echo "[WARN] state.md が存在しません"
    echo "git checkout HEAD -- state.md"
fi

# 6. セッション初期化ディレクトリをクリア
if [ -d ".claude/.session-init" ]; then
    echo "[INFO] .session-init をクリア"
    rm -rf .claude/.session-init
fi

echo "=== 復旧確認完了 ==="
```

### 3.2 最小セットアップスクリプト

```bash
#!/bin/bash
# minimal-setup.sh - 最小限のセットアップ

set -e

echo "=== 最小セットアップ開始 ==="

# 必須ディレクトリ作成
mkdir -p .claude/hooks
mkdir -p .claude/agents

# settings.json（最小版）
if [ ! -f ".claude/settings.json" ]; then
    cat > .claude/settings.json << 'SETTINGS'
{
  "permissions": {"defaultMode": "bypassPermissions"},
  "hooks": {
    "PreToolUse": [
      {"matcher": "Edit", "hooks": [{"type": "command", "command": "bash .claude/hooks/playbook-guard.sh"}]}
    ]
  }
}
SETTINGS
    echo "[OK] settings.json 作成"
fi

# playbook-guard.sh（最小版）
if [ ! -f ".claude/hooks/playbook-guard.sh" ]; then
    cat > .claude/hooks/playbook-guard.sh << 'GUARD'
#!/bin/bash
[ ! -f "state.md" ] && exit 0
grep -q "playbook: null" state.md && echo "playbook 必須" >&2 && exit 2
exit 0
GUARD
    chmod +x .claude/hooks/playbook-guard.sh
    echo "[OK] playbook-guard.sh 作成"
fi

# state.md（最小版）
if [ ! -f "state.md" ]; then
    cat > state.md << 'STATE'
# state.md

## focus
```yaml
current: product
```

## active_playbooks
```yaml
product: null
```
STATE
    echo "[OK] state.md 作成"
fi

echo "=== 最小セットアップ完了 ==="
```

---

## 4. コンポーネント別復旧テンプレート

### 4.1 Hook テンプレート

```bash
# .claude/hooks/{hook-name}.sh
#!/bin/bash
set -euo pipefail

# stdin から JSON を読み込む
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# 条件チェック
if [[ 条件 ]]; then
    echo "エラーメッセージ" >&2
    exit 2  # ブロック
fi

exit 0  # 許可
```

### 4.2 SubAgent テンプレート

```markdown
---
name: agent-name
description: PROACTIVELY/AUTOMATICALLY + 機能説明
tools: Read, Grep, Bash
model: haiku
---

エージェントへの指示をここに記載
```

### 4.3 Skill テンプレート

```markdown
---
name: skill-name
description: 機能説明（自動発見のトリガーキーワードを含める）
---

スキルの詳細説明と指示
```

---

## 5. 復旧確認チェックリスト

```
□ settings.json が存在し、JSON として有効
□ session-start.sh が実行可能
□ init-guard.sh が実行可能
□ playbook-guard.sh が実行可能
□ critic-guard.sh が実行可能
□ critic.md が存在
□ pm.md が存在
□ state.md が存在し、YAML として有効
□ .claude/.session-init/ が空またはクリア済み
□ 新セッションを開始して session-start.sh の出力を確認
□ state.md を Read して init-guard.sh が解除されることを確認
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-09 | Phase 6 完了。シナリオ別復旧手順、復旧スクリプト、チェックリストを作成。 |

---

**作成日時**: 2025-12-09
**作成者**: Claude Code（P6 実行）
**状態**: ✅ 完了、Phase 7 へ移行可能
