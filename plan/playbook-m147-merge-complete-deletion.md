# playbook-m147-merge-complete-deletion.md

> **MERGE済ドキュメント削除: 統合完了ファイルの安全な削除**
>
> M146 に続くコンテキスト収束の第2弾。
> 内容が既に統合先に存在する6ファイルを削除する。

---

## meta

```yaml
schema_version: v2
project: context-consolidation
branch: feat/m147-merge-complete-deletion
created: 2025-12-21
issue: null
derives_from: M147
reviewed: true  # Codex レビュー PASS（参照更新 phase 追加後）
roles:
  worker: claudecode
  reviewer: codex  # Codex レビュー必須

user_prompt_original: |
  M147: MERGE済ドキュメント削除
  - 6件のMERGE済ファイルを削除（内容は既に統合先に存在）
  - FREEZE_QUEUE から DELETE_LOG へ移動
  - テストが全て PASS すること
```

---

## goal

```yaml
summary: 統合完了済みの6ファイルを安全に削除し、コンテキストを削減する
done_when:
  - "6件のMERGE済ファイルが削除されている"
  - "統合先ファイルに内容が存在することが確認されている"
  - "削除対象への参照が他ファイルから除去/更新されている"
  - "FREEZE_QUEUE から DELETE_LOG へ移動されている"
  - "削除後も全テスト（flow-runtime-test）が PASS する"
```

---

## phases

### p1: 統合先の内容確認

**goal**: 削除対象の内容が統合先に存在することを確認する

#### subtasks

- [ ] **p1.1**: docs/admin-contract.md の内容が docs/core-contract.md に存在する
  - executor: claudecode
  - test_command: `grep -q "Admin Mode" docs/core-contract.md && echo PASS || echo FAIL`
  - validations:
    - technical: "Admin Mode Contract が core-contract.md に含まれている"
    - consistency: "元ファイルの主要セクションが移行済み"
    - completeness: "重要な定義が欠落していない"

- [ ] **p1.2**: docs/archive-operation-rules.md の内容が docs/folder-management.md に存在する
  - executor: claudecode
  - test_command: `grep -q "archive" docs/folder-management.md && echo PASS || echo FAIL`
  - validations:
    - technical: "アーカイブ操作ルールが folder-management.md に含まれている"
    - consistency: "plan/archive/ のルールが記載されている"
    - completeness: "アーカイブフローが文書化されている"

- [ ] **p1.3**: docs/artifact-management-rules.md の内容が docs/folder-management.md に存在する
  - executor: claudecode
  - test_command: `grep -q "artifact\|成果物" docs/folder-management.md && echo PASS || echo FAIL`
  - validations:
    - technical: "成果物管理ルールが folder-management.md に含まれている"
    - consistency: "配置ルールが統合されている"
    - completeness: "tmp/ の扱いが文書化されている"

- [ ] **p1.4**: docs/completion-criteria.md の内容が docs/verification-criteria.md に存在する
  - executor: claudecode
  - test_command: `grep -q "done_when\|完了基準" docs/verification-criteria.md && echo PASS || echo FAIL`
  - validations:
    - technical: "完了基準が verification-criteria.md に含まれている"
    - consistency: "critic 評価基準と統合されている"
    - completeness: "phase 完了ルールが文書化されている"

- [ ] **p1.5**: docs/orchestration-contract.md の内容が docs/ai-orchestration.md に存在する
  - executor: claudecode
  - test_command: `grep -q "orchestrator\|調整" docs/ai-orchestration.md && echo PASS || echo FAIL`
  - validations:
    - technical: "Orchestration Contract が ai-orchestration.md に含まれている"
    - consistency: "役割定義と統合されている"
    - completeness: "claudecode の責務が文書化されている"

- [ ] **p1.6**: docs/toolstack-patterns.md の内容が docs/ai-orchestration.md に存在する
  - executor: claudecode
  - test_command: `grep -q "toolstack\|Toolstack" docs/ai-orchestration.md && echo PASS || echo FAIL`
  - validations:
    - technical: "Toolstack パターンが ai-orchestration.md に含まれている"
    - consistency: "A/B/C パターンが記載されている"
    - completeness: "executor 選択ロジックが文書化されている"

**status**: done
**max_iterations**: 3

---

### p2: MERGE済ファイルの削除

**goal**: 6件のファイルを削除する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: docs/admin-contract.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/admin-contract.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "git rm で追跡から除外されている"
    - completeness: "参照エラーがない"

- [ ] **p2.2**: docs/archive-operation-rules.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/archive-operation-rules.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "git rm で追跡から除外されている"
    - completeness: "参照エラーがない"

- [ ] **p2.3**: docs/artifact-management-rules.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/artifact-management-rules.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "git rm で追跡から除外されている"
    - completeness: "参照エラーがない"

- [ ] **p2.4**: docs/completion-criteria.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/completion-criteria.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "git rm で追跡から除外されている"
    - completeness: "参照エラーがない"

- [ ] **p2.5**: docs/orchestration-contract.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/orchestration-contract.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "git rm で追跡から除外されている"
    - completeness: "参照エラーがない"

- [ ] **p2.6**: docs/toolstack-patterns.md が削除されている
  - executor: claudecode
  - test_command: `test ! -f docs/toolstack-patterns.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "git rm で追跡から除外されている"
    - completeness: "参照エラーがない"

**status**: done
**max_iterations**: 3

---

### p2_ref: 参照の更新

**goal**: 削除対象ファイルへの参照を統合先に更新または除去

**depends_on**: [p2]

#### subtasks

- [ ] **p2_ref.1**: docs/essential-documents.md から削除対象の参照を除去
  - executor: claudecode
  - test_command: `! grep -q "admin-contract.md\|archive-operation-rules.md\|artifact-management-rules.md\|completion-criteria.md\|orchestration-contract.md\|toolstack-patterns.md" docs/essential-documents.md && echo PASS || echo FAIL`
  - validations:
    - technical: "削除対象ファイル名が含まれていない"
    - consistency: "FREEZE_QUEUE セクションから除外されている"
    - completeness: "統合先への参照は維持されている"

- [ ] **p2_ref.2**: setup/playbook-setup.md の参照を統合先に更新
  - executor: claudecode
  - test_command: `! grep -q "docs/toolstack-patterns.md" setup/playbook-setup.md && echo PASS || echo FAIL`
  - validations:
    - technical: "toolstack-patterns.md への参照がない"
    - consistency: "ai-orchestration.md への参照に更新されている"
    - completeness: "機能説明は維持されている"

- [ ] **p2_ref.3**: .claude/hooks/archive-playbook.sh の参照を更新
  - executor: claudecode
  - test_command: `! grep -q "archive-operation-rules.md" .claude/hooks/archive-playbook.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "archive-operation-rules.md への参照がない"
    - consistency: "folder-management.md への参照に更新されている"
    - completeness: "Hook 機能は維持されている"

- [ ] **p2_ref.4**: .claude/skills/post-loop/SKILL.md の参照を更新
  - executor: claudecode
  - test_command: `! grep -q "archive-operation-rules.md" .claude/skills/post-loop/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "archive-operation-rules.md への参照がない"
    - consistency: "folder-management.md への参照に更新されている"
    - completeness: "Skill 機能は維持されている"

**status**: done
**max_iterations**: 3

---

### p3: state.md 更新

**goal**: FREEZE_QUEUE から DELETE_LOG へ移動

**depends_on**: [p2_ref]

#### subtasks

- [ ] **p3.1**: 6件が FREEZE_QUEUE から除外されている
  - executor: claudecode
  - test_command: `! grep -q "admin-contract.md\|archive-operation-rules.md\|artifact-management-rules.md\|completion-criteria.md\|orchestration-contract.md\|toolstack-patterns.md" <(grep -A50 "## FREEZE_QUEUE" state.md | grep -B50 "freeze_period_days") && echo PASS || echo FAIL`
  - validations:
    - technical: "FREEZE_QUEUE に対象ファイルが含まれていない"
    - consistency: "DELETE_LOG に記録されている"
    - completeness: "全6ファイルが処理されている"

- [ ] **p3.2**: docs/essential-documents.md を再生成
  - executor: claudecode
  - test_command: `bash scripts/generate-essential-docs.sh && ! grep -q "admin-contract.md\|archive-operation-rules.md" docs/essential-documents.md && echo PASS || echo FAIL`
  - validations:
    - technical: "再生成が成功している"
    - consistency: "削除対象ファイルがリストから除外されている"
    - completeness: "FREEZE_QUEUE 更新後の state.md を反映している"

**status**: done
**note**: repository-map.yaml は FREEZE_QUEUE 中のため再生成不要（生成スクリプトも M126 で削除済み）
**max_iterations**: 3

---

### p_final: 完了検証

**goal**: 全ての done_when が満たされているか最終検証

**depends_on**: [p3]

#### subtasks

- [ ] **p_final.1**: 6件のMERGE済ファイルが削除されている
  - executor: claudecode
  - test_command: |
    test ! -f docs/admin-contract.md && \
    test ! -f docs/archive-operation-rules.md && \
    test ! -f docs/artifact-management-rules.md && \
    test ! -f docs/completion-criteria.md && \
    test ! -f docs/orchestration-contract.md && \
    test ! -f docs/toolstack-patterns.md && \
    echo PASS || echo FAIL
  - validations:
    - technical: "全6ファイルが存在しない"
    - consistency: "DELETE_LOG に記録されている"
    - completeness: "削除完了"

- [ ] **p_final.2**: 削除対象への参照が除去されている
  - executor: claudecode
  - test_command: `! grep -rq "admin-contract.md\|archive-operation-rules.md\|artifact-management-rules.md\|completion-criteria.md\|orchestration-contract.md\|toolstack-patterns.md" docs/ .claude/hooks/ .claude/skills/ setup/ --include="*.md" --include="*.sh" --exclude="user-intent.md" 2>/dev/null && echo PASS || echo FAIL`
  - validations:
    - technical: "参照が残っていない（DELETE_LOG/ログ除く）"
    - consistency: "統合先への参照に更新されている"
    - completeness: "全ての参照が処理されている"
  - note: "state.md の DELETE_LOG、.session-init/user-intent.md は記録のため除外"

- [ ] **p_final.3**: テストが全て PASS する
  - executor: claudecode
  - test_command: `bash scripts/flow-runtime-test.sh 2>&1 | grep -q "ALL.*PASS" && echo PASS || echo FAIL`
  - validations:
    - technical: "テストが正常に実行される"
    - consistency: "削除がシステムに悪影響を与えていない"
    - completeness: "主要テストが全て PASS"

**status**: done
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## rollback

```yaml
手順:
  1. git checkout -- で削除ファイルを復元
     git checkout HEAD -- docs/admin-contract.md
     git checkout HEAD -- docs/archive-operation-rules.md
     git checkout HEAD -- docs/artifact-management-rules.md
     git checkout HEAD -- docs/completion-criteria.md
     git checkout HEAD -- docs/orchestration-contract.md
     git checkout HEAD -- docs/toolstack-patterns.md

  2. state.md の FREEZE_QUEUE を復元
     git checkout HEAD -- state.md

注意:
  - ブランチが feat/m147-merge-complete-deletion であることを確認
  - main にはマージされていないため、ブランチ削除でも復元可能
```

---

## notes

### 削除対象ファイルと統合先

```yaml
削除対象:
  - docs/admin-contract.md:
      統合先: docs/core-contract.md
      理由: M122 で Admin Mode Contract として統合済み

  - docs/archive-operation-rules.md:
      統合先: docs/folder-management.md
      理由: M122 でアーカイブ操作ルールとして統合済み

  - docs/artifact-management-rules.md:
      統合先: docs/folder-management.md
      理由: M122 で成果物管理ルールとして統合済み

  - docs/completion-criteria.md:
      統合先: docs/verification-criteria.md
      理由: M122 で完了基準として統合済み

  - docs/orchestration-contract.md:
      統合先: docs/ai-orchestration.md
      理由: M122 で Orchestration Contract として統合済み

  - docs/toolstack-patterns.md:
      統合先: docs/ai-orchestration.md
      理由: M122 で Toolstack パターンとして統合済み
```

### 削減効果

```yaml
削除ファイル数: 6
削減サイズ: 約 35KB
M146 からの累計: 15 ファイル削減
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
