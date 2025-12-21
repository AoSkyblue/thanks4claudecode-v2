# playbook-m145-manifest-integrity.md

> **core-manifest.yaml 整合性検証と修正**

---

## meta

```yaml
schema_version: v2
project: M145-manifest-integrity
branch: feat/m145-manifest-integrity
created: 2025-12-21
issue: null
derives_from: null
reviewed: false
roles:
  worker: claudecode

user_prompt_original: |
  M145: core-manifest.yaml 整合性検証と修正
  - trigger 情報が settings.json の実態と一致していない
  - 欠落しているコンポーネントがある可能性
  - SUMMARY セクションの数値が不正確
  - テストが全て PASS すること
```

---

## goal

```yaml
summary: core-manifest.yaml の全 trigger が settings.json と一致し、全コンポーネントが正確に記載されている
done_when:
  - core-manifest.yaml の全 Hook trigger が settings.json と一致している
  - 全ての実装済みコンポーネント（Hook/SubAgent/Command/Skill）が manifest に含まれている
  - SUMMARY セクションの数値が実際のコンポーネント数と一致している
  - テスト（flow-runtime-test, e2e-contract-test, verify-manifest）が全て PASS する
```

---

## phases

### p1: 現状調査

**goal**: settings.json と core-manifest.yaml の不一致を特定し、不一致リストを作成する

#### subtasks

- [ ] **p1.1**: settings.json から全 Hook の trigger を抽出し、tmp/settings-triggers.md に全 trigger タイプが記録されている
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    test -f tmp/settings-triggers.md
    grep -c "trigger:" tmp/settings-triggers.md | grep -qE "^[1-9][0-9]?$"
    grep -q "PreToolUse" tmp/settings-triggers.md
    grep -q "PostToolUse" tmp/settings-triggers.md
    grep -q "UserPromptSubmit" tmp/settings-triggers.md
    grep -q "SessionStart" tmp/settings-triggers.md
    grep -q "SessionEnd" tmp/settings-triggers.md
    grep -q "Stop" tmp/settings-triggers.md
    grep -q "PreCompact" tmp/settings-triggers.md
  - validations:
    - technical: "抽出コマンドが正常に動作する"
    - consistency: "全ての Hook trigger が抽出されている"
    - completeness: "PreToolUse, PostToolUse, UserPromptSubmit, SessionStart, SessionEnd, Stop, PreCompact 全 trigger タイプを含む"

- [ ] **p1.2**: .claude/hooks/, agents/, commands/, skills/ の実ファイルが tmp/actual-components.md に列挙され、.sh と .md ファイルを含む
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    test -f tmp/actual-components.md
    grep -q "hooks/" tmp/actual-components.md
    grep -q "agents/" tmp/actual-components.md
    grep -q "commands/" tmp/actual-components.md
    grep -q "skills/" tmp/actual-components.md
    grep -q "\.sh" tmp/actual-components.md
    grep -q "\.md" tmp/actual-components.md
  - validations:
    - technical: "ls コマンドが全ディレクトリを列挙できる"
    - consistency: "全ディレクトリが対象に含まれている"
    - completeness: "全ファイル形式（.sh, .md）が含まれている"

- [ ] **p1.3**: core-manifest.yaml の定義と実態の不一致リストが tmp/discrepancies.md に記録され、各カテゴリの比較結果を含む
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    test -f tmp/discrepancies.md
    grep -qE "^## (結果|Summary|不一致|Discrepancies)" tmp/discrepancies.md
    grep -q "Hook" tmp/discrepancies.md
    grep -q "SubAgent\|Agent" tmp/discrepancies.md
    grep -q "Command" tmp/discrepancies.md
    grep -q "Skill" tmp/discrepancies.md
  - validations:
    - technical: "比較ロジックが正しく動作する"
    - consistency: "全カテゴリ（Hook/SubAgent/Command/Skill）が比較されている"
    - completeness: "trigger 情報、欠落、重複が全て検出されている"

**status**: pending
**max_iterations**: 5

---

### p2: 修正実行

**goal**: 発見された不一致を全て修正する
**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: core-manifest.yaml の Hook trigger が settings.json と一致している
  - executor: claudecode
  - test_command: `bash -o pipefail -c 'bash scripts/verify-manifest.sh 2>&1 | grep -q "仕様と実態が完全に一致"'`
  - validations:
    - technical: "YAML 構文が正しい"
    - consistency: "settings.json の全 Hook が manifest に反映されている"
    - completeness: "trigger タイプが正確に記載されている"

- [ ] **p2.2**: 全コンポーネント（Hook/SubAgent/Command/Skill）の名前が core-manifest.yaml に含まれている
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    # Hook 名が manifest に含まれているか
    for hook in $(ls .claude/hooks/*.sh 2>/dev/null | xargs -I{} basename {}); do
      grep -q "$hook" governance/core-manifest.yaml
    done
    # SubAgent 名が manifest に含まれているか
    for agent in $(ls .claude/agents/*.md 2>/dev/null | xargs -I{} basename {} .md); do
      grep -q "$agent" governance/core-manifest.yaml
    done
    # Command 名が manifest に含まれているか
    for cmd in $(ls .claude/commands/*.md 2>/dev/null | xargs -I{} basename {} .md); do
      grep -q "$cmd" governance/core-manifest.yaml
    done
    # Skill 名が manifest に含まれているか
    for skill in $(ls -d .claude/skills/*/ 2>/dev/null | xargs -I{} basename {}); do
      grep -q "$skill" governance/core-manifest.yaml
    done
  - validations:
    - technical: "追加されたコンポーネントの記述が正しい"
    - consistency: "Layer 配置が適切である"
    - completeness: "Hook/SubAgent/Command/Skill 全てが manifest にある"

- [ ] **p2.3**: SUMMARY セクションの Total 数値が manifest 内のコンポーネント数と一致している
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    TOTAL_IN_SUMMARY=$(grep -A10 "# SUMMARY" governance/core-manifest.yaml | grep "総計:" | grep -oE "[0-9]+")
    ACTUAL_TOTAL=$(grep -cE "^      - name:" governance/core-manifest.yaml)
    [ "$TOTAL_IN_SUMMARY" = "$ACTUAL_TOTAL" ]
  - validations:
    - technical: "計算が正しい"
    - consistency: "各動線の数値が正確"
    - completeness: "Core/Quality/Extension の合計が Total と一致"

- [ ] **p2.4**: generate-essential-docs.sh の数値定義が core-manifest.yaml の SUMMARY と一致している
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    # manifest の SUMMARY からコンポーネント数を取得
    MANIFEST_PLANNING=$(grep -A20 "planning_flow:" governance/core-manifest.yaml | grep -c "^      - name:" || echo 0)
    MANIFEST_VERIFICATION=$(grep -A20 "verification_flow:" governance/core-manifest.yaml | grep -c "^      - name:" || echo 0)
    MANIFEST_EXECUTION=$(grep -A30 "execution_flow:" governance/core-manifest.yaml | grep -c "^      - name:" || echo 0)
    # generate-essential-docs.sh から数値を取得
    SCRIPT_PLANNING=$(grep -oE "planning=[0-9]+" scripts/generate-essential-docs.sh | grep -oE "[0-9]+")
    SCRIPT_VERIFICATION=$(grep -oE "verification=[0-9]+" scripts/generate-essential-docs.sh | grep -oE "[0-9]+")
    SCRIPT_EXECUTION=$(grep -oE "execution=[0-9]+" scripts/generate-essential-docs.sh | grep -oE "[0-9]+")
    # 比較
    [ "$MANIFEST_PLANNING" = "$SCRIPT_PLANNING" ]
    [ "$MANIFEST_VERIFICATION" = "$SCRIPT_VERIFICATION" ]
    [ "$MANIFEST_EXECUTION" = "$SCRIPT_EXECUTION" ]
  - validations:
    - technical: "スクリプト構文が正しい"
    - consistency: "manifest の SUMMARY と一致"
    - completeness: "全変数が定義されている"

**status**: pending
**max_iterations**: 5

---

### p3: 検証

**goal**: 全てのテストが PASS することを確認する
**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: essential-documents.md が再生成され、manifest の内容（総数・セクション名）を反映している
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    bash scripts/generate-essential-docs.sh
    grep -q "$(date +%Y-%m-%d)" docs/essential-documents.md
    grep -q "core-manifest.yaml" docs/essential-documents.md
    grep -q "計画動線" docs/essential-documents.md
    # manifest の Total と essential-documents.md の Total が一致
    MANIFEST_TOTAL=$(grep -A10 "# SUMMARY" governance/core-manifest.yaml | grep "総計:" | grep -oE "[0-9]+")
    grep -q "Total: $MANIFEST_TOTAL" docs/essential-documents.md
  - validations:
    - technical: "スクリプトがエラーなく実行される"
    - consistency: "出力が core-manifest.yaml と整合"
    - completeness: "全セクションが生成されている"

- [ ] **p3.2**: verify-manifest.sh が「仕様と実態が完全に一致」を返す
  - executor: claudecode
  - test_command: `bash -o pipefail -c 'bash scripts/verify-manifest.sh 2>&1 | grep -q "仕様と実態が完全に一致"'`
  - validations:
    - technical: "テストが正常に実行される"
    - consistency: "全 Hook が REGISTERED"
    - completeness: "逆引きチェックも PASS"

- [ ] **p3.3**: flow-runtime-test.sh が「ALL.*PASSED」を返す
  - executor: claudecode
  - test_command: `bash -o pipefail -c 'bash scripts/flow-runtime-test.sh 2>&1 | tail -5 | grep -q "ALL.*PASSED"'`
  - validations:
    - technical: "テストが正常に実行される"
    - consistency: "4 動線全てが検証される"
    - completeness: "全テストが PASS"

- [ ] **p3.4**: e2e-contract-test.sh が「ALL.*PASSED」を返す
  - executor: claudecode
  - test_command: `bash -o pipefail -c 'bash scripts/e2e-contract-test.sh 2>&1 | tail -5 | grep -q "ALL.*PASSED"'`
  - validations:
    - technical: "テストが正常に実行される"
    - consistency: "全パターンが検証される"
    - completeness: "全テストが PASS"

- [ ] **p3.5**: tmp/ の中間成果物が削除されている
  - executor: claudecode
  - test_command: `test ! -f tmp/settings-triggers.md && test ! -f tmp/actual-components.md && test ! -f tmp/discrepancies.md`
  - validations:
    - technical: "削除コマンドが正常に動作"
    - consistency: "全中間成果物が対象"
    - completeness: "tmp/ がクリーンな状態"

**status**: pending
**max_iterations**: 3

---

### p_final: 完了検証（必須）

**goal**: playbook の done_when が全て満たされているか最終検証
**depends_on**: [p3]

#### subtasks

- [ ] **p_final.1**: core-manifest.yaml の全 Hook trigger が settings.json と一致している
  - executor: claudecode
  - test_command: `bash -o pipefail -c 'bash scripts/verify-manifest.sh 2>&1 | grep -q "仕様と実態が完全に一致"'`
  - validations:
    - technical: "検証コマンドが正常に実行できる"
    - consistency: "verify-manifest.sh の結果が実際の状態と一致"
    - completeness: "全 Hook が検証対象"

- [ ] **p_final.2**: 全ての実装済みコンポーネント（Hook/SubAgent/Command/Skill）が manifest に含まれている
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    # Hook 名が manifest に含まれているか
    for hook in $(ls .claude/hooks/*.sh 2>/dev/null | xargs -I{} basename {}); do
      grep -q "$hook" governance/core-manifest.yaml
    done
    # SubAgent 名が manifest に含まれているか
    for agent in $(ls .claude/agents/*.md 2>/dev/null | xargs -I{} basename {} .md); do
      grep -q "$agent" governance/core-manifest.yaml
    done
    # Command 名が manifest に含まれているか
    for cmd in $(ls .claude/commands/*.md 2>/dev/null | xargs -I{} basename {} .md); do
      grep -q "$cmd" governance/core-manifest.yaml
    done
    # Skill 名が manifest に含まれているか
    for skill in $(ls -d .claude/skills/*/ 2>/dev/null | xargs -I{} basename {}); do
      grep -q "$skill" governance/core-manifest.yaml
    done
  - validations:
    - technical: "カウントロジックが正しい"
    - consistency: "全カテゴリがカウント対象"
    - completeness: "deletion_candidates も考慮"

- [ ] **p_final.3**: SUMMARY セクションの数値が実際のコンポーネント数と一致している
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    TOTAL_IN_SUMMARY=$(grep -A10 "# SUMMARY" governance/core-manifest.yaml | grep "総計:" | grep -oE "[0-9]+")
    ACTUAL_TOTAL=$(grep -cE "^      - name:" governance/core-manifest.yaml)
    [ "$TOTAL_IN_SUMMARY" = "$ACTUAL_TOTAL" ]
  - validations:
    - technical: "grep が正しいセクションを抽出"
    - consistency: "各動線の合計が Total と一致"
    - completeness: "全 Layer が含まれている"

- [ ] **p_final.4**: 全テストが PASS している
  - executor: claudecode
  - test_command: |
    set -eo pipefail
    bash scripts/verify-manifest.sh 2>&1 | grep -q "仕様と実態が完全に一致"
    bash scripts/flow-runtime-test.sh 2>&1 | tail -3 | grep -q "ALL.*PASSED"
    bash scripts/e2e-contract-test.sh 2>&1 | tail -3 | grep -q "ALL.*PASSED"
  - validations:
    - technical: "全テストスクリプトが実行可能"
    - consistency: "テスト結果が一貫している"
    - completeness: "3 つのテストスイートが全て PASS"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: tmp/ 内の一時ファイルを削除する
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true`
  - status: pending

- [ ] **ft2**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## 実施した修正内容（動線単位）

### 計画動線（Core）

| 修正 | 内容 |
|-----|------|
| reviewer.md 追加 | 計画動線に SubAgent として追加。pm 作成後の playbook 品質検証を担当。 |

### 検証動線（Core）

| 修正 | 内容 |
|-----|------|
| critic-guard.sh trigger | PostToolUse → PreToolUse:Edit,Write に修正 |
| test 型修正 | skill → command (test.md) に修正 |
| lint 型修正 | skill → command (lint.md) に修正 |

### 実行動線（Quality）

| 修正 | 内容 |
|-----|------|
| init-guard.sh trigger | PreToolUse → PreToolUse:* に修正 |
| subtask-guard.sh trigger | PreToolUse:Edit → PreToolUse:Edit,Write に修正 |
| scope-guard.sh trigger | PreToolUse:Edit → PreToolUse:Edit,Write に修正 |
| check-protected-edit.sh trigger | PreToolUse:Edit → PreToolUse:Edit,Write に修正 |
| check-main-branch.sh trigger | PreToolUse:Edit,Write → PreToolUse:* に修正 |

### 完了動線（Extension）

| 修正 | 内容 |
|-----|------|
| post-loop 型修正 | skill → command (post-loop.md) に修正 |
| focus.md 追加 | 完了動線に command として追加 |

### 共通基盤（Extension）

| 修正 | 内容 |
|-----|------|
| pre-compact.sh trigger | (なし) → PreCompact を追加 |
| stop-summary.sh trigger | (なし) → Stop を追加 |
| log-subagent.sh trigger | (なし) → PostToolUse:Task を追加 |
| compact.md 追加 | 共通基盤に command として追加 |

### SUMMARY 更新

| 項目 | 修正前 | 修正後 |
|-----|-------|-------|
| 計画動線 | 6 | 7 |
| 完了動線 | 7 | 7 |
| 共通基盤 | 5 | 6 |
| 総計 | 36 | 38 |

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
| 2025-12-21 | Codex レビュー指摘対応: test_command を非ゼロ終了で失敗検知可能に修正、p_final に depends_on 追加、全カテゴリ（Hook/SubAgent/Command/Skill）検証に拡張 |
| 2025-12-21 | Codex レビュー2回目指摘対応: pipefail 追加、名前ベースの検証に変更、p1.x の完全性チェック強化、p3.1 の内容検証追加 |
| 2025-12-21 | Codex レビュー3回目指摘対応: p2.2 に Command/Skill 検証追加、p2.4 に数値比較ロジック追加、p1.1 に全 trigger タイプ検証追加、p1.2 にファイル形式検証追加、p1.3 に全カテゴリ検証追加、p3.1 に manifest Total 検証追加 |
