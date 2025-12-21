# playbook-m146-context-consolidation.md

> **コンテキスト収束: 安全な削除とバグ修正**
>
> 詳細分析レポート（tmp/deep-analysis-report.md）に基づく実行計画。
> Codex レビューの制約を遵守。

---

## meta

```yaml
schema_version: v2
project: context-consolidation
branch: feat/m146-context-consolidation
created: 2025-12-21
issue: null
derives_from: M146
reviewed: true
roles:
  worker: claudecode  # ファイル削除・軽量修正のため

user_prompt_original: |
  Create a playbook for context consolidation based on the reviewed analysis.
  Read the analysis at: tmp/deep-analysis-report.md
  Key constraints from Codex review:
  1. DO NOT delete .claude/tests/* (referenced by pre-bash-check.sh)
  2. DO NOT immediately delete repository-map.yaml (needs migration first)
  3. DO NOT merge hooks (maintainability concern)
  Safe to execute now:
  1. Delete plan/ duplicates (M127, M142 - already in archive)
  2. Delete docs/ DISCARD files (7 files with no references)
  3. Fix prompt-guard.sh path bug (plan/mission.md -> plan/design/mission.md)
```

---

## goal

```yaml
summary: 分析レポートに基づく安全なコンテキスト削減とバグ修正
done_when:
  - "plan/ の重複ファイル（M127, M142）が削除されている"
  - "docs/ の DISCARD 判定ファイル（7件）が削除されている"
  - "prompt-guard.sh のパスバグが修正されている"
  - "削除後も全テスト（flow-runtime-test, e2e-contract-test）が PASS する"
```

---

## phases

### p1: plan/ 重複ファイルの削除

**goal**: archive/ に既にあるファイルを plan/ から削除する

#### subtasks

- [ ] **p1.1**: plan/playbook-m127-playbook-reviewer-automation.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f plan/playbook-m127-playbook-reviewer-automation.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "plan/archive/ に同名ファイルが存在する"
    - completeness: "git rm で追跡から除外されている"

- [ ] **p1.2**: plan/playbook-m142-hook-tests.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f plan/playbook-m142-hook-tests.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "plan/archive/ に同名ファイルが存在する"
    - completeness: "git rm で追跡から除外されている"

**status**: done
**max_iterations**: 3

---

### p2: docs/ DISCARD ファイルの削除

**goal**: 役割を終えた7件のドキュメントを削除する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: docs/current-definitions.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/current-definitions.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "他ファイルから参照されていない"
    - completeness: "FREEZE_QUEUE から削除されている（または DELETE_LOG に記録）"

- [ ] **p2.2**: docs/deprecated-references.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/deprecated-references.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "他ファイルから参照されていない"
    - completeness: "FREEZE_QUEUE から削除されている"

- [ ] **p2.3**: docs/document-catalog.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/document-catalog.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "essential-documents.md で代替済み"
    - completeness: "FREEZE_QUEUE から削除されている"

- [ ] **p2.4**: docs/flow-test-report.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/flow-test-report.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "M107 完了報告、役割終了"
    - completeness: "FREEZE_QUEUE から削除されている"

- [ ] **p2.5**: docs/golden-path-verification-report.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/golden-path-verification-report.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "M105 完了報告、役割終了"
    - completeness: "FREEZE_QUEUE から削除されている"

- [ ] **p2.6**: docs/m106-critic-guard-patch.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/m106-critic-guard-patch.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "M106 パッチ適用済み、役割終了"
    - completeness: "FREEZE_QUEUE から削除されている"

- [ ] **p2.7**: docs/scenario-test-report.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/scenario-test-report.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "M110 完了報告、役割終了"
    - completeness: "FREEZE_QUEUE から削除されている"

**status**: done
**max_iterations**: 5

---

### p3: prompt-guard.sh パスバグ修正

**goal**: mission.md の正しいパスを設定する

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: prompt-guard.sh の MISSION_FILE が "plan/design/mission.md" に修正されている
  - executor: claudecode
  - test_command: `grep -q 'MISSION_FILE="plan/design/mission.md"' .claude/hooks/prompt-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "正しいパスが設定されている"
    - consistency: "plan/design/mission.md が実際に存在する"
    - completeness: "変更行以外は影響を受けていない"

- [ ] **p3.2**: prompt-guard.sh が正常に実行可能である
  - executor: claudecode
  - test_command: `bash -n .claude/hooks/prompt-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "シンタックスエラーがない"
    - consistency: "Hook として正常に動作可能"
    - completeness: "他の機能に影響がない"

**status**: done
**max_iterations**: 3

---

### p4: state.md の FREEZE_QUEUE 更新

**goal**: 削除したファイルを FREEZE_QUEUE から DELETE_LOG へ移動

**depends_on**: [p3]

#### subtasks

- [ ] **p4.1**: 削除した9ファイルが FREEZE_QUEUE から除外されている
  - executor: claudecode
  - test_command: `! grep -q "current-definitions.md\|deprecated-references.md\|document-catalog.md\|flow-test-report.md\|golden-path-verification-report.md\|m106-critic-guard-patch.md\|scenario-test-report.md" state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "FREEZE_QUEUE に対象ファイルが含まれていない"
    - consistency: "DELETE_LOG に記録されている"
    - completeness: "全9ファイル（plan 2件 + docs 7件）が処理されている"

**status**: done
**max_iterations**: 3

---

### p_final: 完了検証（必須）

**goal**: 全ての done_when が満たされているか最終検証

**depends_on**: [p4]

#### subtasks

- [ ] **p_final.1**: plan/ の重複ファイルが削除されている
  - executor: claudecode
  - test_command: `test ! -f plan/playbook-m127-playbook-reviewer-automation.md && test ! -f plan/playbook-m142-hook-tests.md && echo PASS || echo FAIL`
  - validations:
    - technical: "両ファイルが存在しない"
    - consistency: "archive/ に正本が存在する"
    - completeness: "削除完了"

- [ ] **p_final.2**: docs/ の DISCARD ファイルが削除されている
  - executor: claudecode
  - test_command: |
    test ! -f docs/current-definitions.md && \
    test ! -f docs/deprecated-references.md && \
    test ! -f docs/document-catalog.md && \
    test ! -f docs/flow-test-report.md && \
    test ! -f docs/golden-path-verification-report.md && \
    test ! -f docs/m106-critic-guard-patch.md && \
    test ! -f docs/scenario-test-report.md && \
    echo PASS || echo FAIL
  - validations:
    - technical: "全7ファイルが存在しない"
    - consistency: "essential-documents.md が代替として機能"
    - completeness: "FREEZE_QUEUE が更新されている"

- [ ] **p_final.3**: prompt-guard.sh のパスバグが修正されている
  - executor: claudecode
  - test_command: `grep -q 'MISSION_FILE="plan/design/mission.md"' .claude/hooks/prompt-guard.sh && test -f plan/design/mission.md && echo PASS || echo FAIL`
  - validations:
    - technical: "パスが正しく、ファイルも存在する"
    - consistency: "Hook が正常に動作可能"
    - completeness: "他の箇所に同様のバグがない"

- [ ] **p_final.4**: テストが全て PASS する
  - executor: claudecode
  - test_command: `bash scripts/flow-runtime-test.sh 2>&1 | grep -q "PASS\|OK" && echo PASS || echo FAIL`
  - validations:
    - technical: "テストが正常に実行される"
    - consistency: "削除がシステムに悪影響を与えていない"
    - completeness: "主要テストが全て PASS"

**status**: done
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

## rollback

```yaml
手順:
  1. git checkout -- で削除ファイルを復元
     git checkout HEAD -- plan/playbook-m127-playbook-reviewer-automation.md
     git checkout HEAD -- plan/playbook-m142-hook-tests.md
     git checkout HEAD -- docs/current-definitions.md
     git checkout HEAD -- docs/deprecated-references.md
     git checkout HEAD -- docs/document-catalog.md
     git checkout HEAD -- docs/flow-test-report.md
     git checkout HEAD -- docs/golden-path-verification-report.md
     git checkout HEAD -- docs/m106-critic-guard-patch.md
     git checkout HEAD -- docs/scenario-test-report.md

  2. prompt-guard.sh のパス修正をリバート
     git checkout HEAD -- .claude/hooks/prompt-guard.sh

  3. state.md の FREEZE_QUEUE を復元
     git checkout HEAD -- state.md

注意:
  - ブランチが feat/m146-context-consolidation であることを確認
  - main にはマージされていないため、ブランチ削除でも復元可能
```

---

## notes

### Codex レビュー制約（遵守必須）

```yaml
禁止事項:
  - .claude/tests/* の削除（pre-bash-check.sh が参照）
  - repository-map.yaml の即時削除（移行が必要）
  - Hook の統合（保守性の懸念）

安全な実行:
  - plan/ 重複ファイル削除（archive/ に正本あり）
  - docs/ DISCARD ファイル削除（参照なし確認済み）
  - prompt-guard.sh パスバグ修正
```

### 削減効果

```yaml
削除ファイル数: 9
  - plan/: 2件（重複）
  - docs/: 7件（DISCARD）

残課題（別タスク）:
  - docs/ MERGE 済ファイル: 6件
  - docs/ MERGE 予定ファイル: 3件
  - repository-map.yaml 移行: 1件
  - context-manifest.yaml 統合検討
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成。Codex レビュー制約を反映。 |
