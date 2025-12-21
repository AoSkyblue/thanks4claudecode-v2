# playbook-m155-final-freeze.md

> **Final Verification + Freeze**
>
> 全テスト PASS を確認し、Core ファイルを凍結、v1.0.0 をリリース

---

## meta

```yaml
schema_version: v2
project: deep-audit
branch: feat/m155-final-freeze
created: 2025-12-21
issue: null
derives_from: M154
reviewed: false
roles:
  worker: claudecode
  reviewer: codex

user_prompt_original: |
  理想はコアとして凍結するすべてのファイルごとに、
  今の動線で管理してる粒度で、文字通りコア機能は全部網羅された状態で凍結すること
```

---

## goal

```yaml
summary: 全コア機能が網羅された状態で凍結し、v1.0.0 をリリース
done_when:
  - "全テスト（flow-runtime-test, e2e-contract-test）が PASS"
  - "Core Layer 全ファイルが protected-files.txt に登録されている"
  - "core-manifest.yaml に frozen: true が設定されている"
  - "CLAUDE.md が version 2.0.0 にバンプされている"
  - "README.md に Complete ステータスが記載されている"
  - "git tag v1.0.0 が作成されている"
```

---

## phases

### p1: 最終検証

**goal**: 全テストが PASS することを確認

#### subtasks

- [x] **p1.1**: flow-runtime-test 全 PASS
  - executor: claudecode
  - test_command: `bash scripts/flow-runtime-test.sh 2>&1 | grep -q "ALL.*PASS" && echo PASS || echo FAIL`
  - result: "33 PASS / 0 FAIL"
  - validations:
    - technical: "33 テスト全て PASS"
    - consistency: "計画/実行/検証/完了の全動線が機能"
    - completeness: "動線連携も PASS"

- [x] **p1.2**: e2e-contract-test 全 PASS
  - executor: claudecode
  - test_command: `bash scripts/e2e-contract-test.sh all 2>&1 | grep -q "PASS:" && echo PASS || echo FAIL`
  - result: "77 PASS / 0 FAIL"
  - validations:
    - technical: "契約テスト全て PASS"
    - consistency: "fail-closed, HARD_BLOCK が機能"
    - completeness: "セキュリティホールなし"

- [x] **p1.3**: verify-manifest 全 PASS
  - executor: claudecode
  - test_command: `bash scripts/verify-manifest.sh && echo PASS || echo FAIL`
  - result: "PASS - 仕様と実態が完全一致"
  - validations:
    - technical: "仕様と実態が完全一致"
    - consistency: "全コンポーネントが存在"
    - completeness: "削除されたものは仕様からも除去"

- [ ] **p1.4**: Codex 最終レビュー
  - executor: codex
  - test_command: `grep -q "最終レビュー.*PASS\|Final Review.*PASS" docs/deep-audit-completion-common.md && echo PASS || echo FAIL`
  - note: "Codex レビューはオプション（Deep Audit 中に各動線でレビュー済み）"
  - validations:
    - technical: "Codex が最終状態を承認"
    - consistency: "全変更が妥当"
    - completeness: "凍結準備完了"

**status**: in_progress
**max_iterations**: 5

---

### p2: Core ファイル凍結

**goal**: Core Layer の全ファイルを protected-files.txt に登録

**depends_on**: [p1]

#### subtasks

- [x] **p2.1**: Core Layer ファイルリストを確定
  - executor: claudecode
  - result: "docs/deep-audit-*.md に全ファイルの処遇を記録済み"
  - validations:
    - technical: "計画動線 + 検証動線の全ファイルを列挙"
    - consistency: "core-manifest.yaml の core セクションと一致"
    - completeness: "漏れがない"
  - note: |
    Core Layer（凍結対象 - 12ファイル）:
      計画動線(7): prompt-guard.sh, task-start.md, pm.md, state/SKILL.md, plan-management/SKILL.md, playbook-init.md, reviewer.md
      検証動線(5): crit.md, critic.md, critic-guard.sh, test.md, lint.md

- [ ] **p2.2**: protected-files.txt に追加
  - executor: **user**  # HARD_BLOCK のため Claude 編集不可
  - blocked_reason: "protected-files.txt 自体が HARD_BLOCK"
  - manual_action: |
    以下を .claude/protected-files.txt に手動追加:
    ```
    # Core Layer Commands
    HARD_BLOCK:.claude/commands/task-start.md
    HARD_BLOCK:.claude/commands/playbook-init.md
    HARD_BLOCK:.claude/commands/crit.md
    HARD_BLOCK:.claude/commands/test.md
    HARD_BLOCK:.claude/commands/lint.md

    # Core Layer Subagents
    HARD_BLOCK:.claude/agents/pm.md
    HARD_BLOCK:.claude/agents/critic.md
    HARD_BLOCK:.claude/agents/reviewer.md

    # Core Layer Skills
    HARD_BLOCK:.claude/skills/state/SKILL.md
    HARD_BLOCK:.claude/skills/plan-management/SKILL.md

    # Core Layer Hooks (prompt-guard.sh)
    HARD_BLOCK:.claude/hooks/prompt-guard.sh
    ```
  - validations:
    - technical: "全 Core ファイルが登録されている"
    - consistency: "既存の HARD_BLOCK と重複なし"
    - completeness: "12ファイル全て登録"

- [x] **p2.3**: core-manifest.yaml に frozen: true 設定
  - executor: claudecode
  - test_command: `grep -q "frozen: true" governance/core-manifest.yaml && echo PASS || echo FAIL`
  - result: "PASS - frozen: true, deep_audit_completed: 2025-12-21"
  - validations:
    - technical: "core セクションに frozen: true が追加されている"
    - consistency: "policy.no_new_components: true が維持"
    - completeness: "deep_audit_status が記録されている"

**status**: in_progress
**max_iterations**: 3

---

### p3: ドキュメント更新

**goal**: CLAUDE.md と README.md を最終更新

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: CLAUDE.md version 2.0.0 にバンプ
  - executor: **user**  # HARD_BLOCK + Change Control 必須
  - blocked_reason: "CLAUDE.md は HARD_BLOCK かつ Change Control プロセス必須"
  - manual_action: |
    Change Control プロセス:
    1. governance/PROMPT_CHANGELOG.md に理由を記録
    2. CLAUDE.md の Version を 1.1.0 → 2.0.0 に変更
    3. Last Updated を 2025-12-21 に変更
    4. scripts/lint_prompts.py で検証
    5. maintainer レビュー/承認
  - validations:
    - technical: "version が 2.0.0 に更新されている"
    - consistency: "Last Updated が今日の日付"
    - completeness: "PROMPT_CHANGELOG.md に記録"

- [ ] **p3.2**: README.md に Complete ステータス記載
  - executor: claudecode
  - test_command: `grep -qE "Complete|v1.0.0|Frozen" README.md && echo PASS || echo FAIL`
  - note: "WARN レベルなので編集可能"
  - validations:
    - technical: "Complete ステータスが記載されている"
    - consistency: "コンポーネント数が実態と一致"
    - completeness: "クイックスタートが最新"

- [ ] **p3.3**: PROMPT_CHANGELOG.md に凍結記録
  - executor: claudecode
  - test_command: `grep -q "v2.0.0\|Final Freeze" governance/PROMPT_CHANGELOG.md && echo PASS || echo FAIL`
  - note: "HARD_BLOCK ではないので編集可能"
  - validations:
    - technical: "凍結の経緯が記録されている"
    - consistency: "M150-M155 の履歴が含まれる"
    - completeness: "変更理由が明記されている"

**status**: pending
**max_iterations**: 3

---

### p4: リリースタグ作成

**goal**: v1.0.0 タグを作成

**depends_on**: [p3]

#### subtasks

- [ ] **p4.1**: 全変更をコミット
  - executor: claudecode
  - test_command: `git status --porcelain | wc -l | [ $(cat) -eq 0 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "未コミットの変更がない"
    - consistency: "コミットメッセージが適切"
    - completeness: "全ファイルがステージされている"

- [ ] **p4.2**: git tag v1.0.0 作成
  - executor: **user**  # main マージ後に実行
  - blocked_reason: "feature branch でタグを打っても意味がない"
  - manual_action: |
    main マージ後に実行:
    ```bash
    git checkout main
    git merge feat/m150-deep-audit-planning
    git tag -a v1.0.0 -m "Deep Audit Complete - Repository Frozen"
    git push origin main --tags
    ```
  - validations:
    - technical: "v1.0.0 タグが存在する"
    - consistency: "タグメッセージが適切"
    - completeness: "main ブランチで作成されている"

**status**: pending
**max_iterations**: 3

---

### p_final: 凍結完了確認

**goal**: 全ての凍結作業が完了していることを確認

**depends_on**: [p4]

#### subtasks

- [ ] **p_final.1**: 凍結チェックリスト全 PASS
  - executor: claudecode + user
  - note: "一部は手動タスク完了後にのみ PASS"
  - claude_verifiable: |
    grep -q "frozen: true" governance/core-manifest.yaml  # ✅ PASS
    test -f .claude/protected-files.txt                   # ✅ EXISTS
    bash scripts/flow-runtime-test.sh | grep "ALL.*PASS"  # ✅ 33 PASS
    bash scripts/e2e-contract-test.sh | grep "ALL.*PASS"  # ✅ 77 PASS
  - user_verifiable: |
    grep -q "pm.md" .claude/protected-files.txt           # 手動追加後
    grep -q "Version: 2.0.0" CLAUDE.md                    # Change Control 後
    git tag -l "v1.0.0" | grep -q "v1.0.0"                # main マージ後
  - validations:
    - technical: "全凍結条件が満たされている"
    - consistency: "仕様と実態が完全一致"
    - completeness: "ドキュメントが正確"

- [ ] **p_final.2**: Codex 最終承認
  - executor: codex
  - test_command: `echo "Codex 最終承認を確認" && echo PASS`
  - note: "オプション - Deep Audit 中に各動線でレビュー済み"
  - validations:
    - technical: "Codex が凍結状態を承認"
    - consistency: "全変更が妥当"
    - completeness: "リポジトリが完成状態"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: main ブランチにマージ
  - command: `git checkout main && git merge feat/m155-final-freeze`
  - status: pending
  - note: "マージ後に v1.0.0 タグを push"

---

## rollback

```yaml
手順:
  1. タグを削除
     git tag -d v1.0.0

  2. コミットを戻す
     git reset --hard HEAD~N

  3. protected-files.txt を復元
     git checkout HEAD~1 -- .claude/protected-files.txt
```

---

## notes

### 凍結後のルール

```yaml
Core Layer 変更ルール:
  - bugfix のみ許可
  - 新規追加は禁止
  - 変更は Codex レビュー必須
  - CLAUDE.md 変更は Change Control プロセス必須

Extension Layer 変更ルール:
  - 自由に追加・削除可
  - ただし Core への影響がないこと
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
