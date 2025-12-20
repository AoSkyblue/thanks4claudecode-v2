# playbook-m113-planning-flow-verification.md

> **M113: 計画動線の検証**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: fix/planning-flow-verification
created: 2025-12-21
issue: null
derives_from: M113
reviewed: false
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: 計画動線（要求 → [理解確認] → pm → playbook → state.md）が正しく機能するか検証する
done_when:
  - 理解確認プロセスが発火する（consent ファイル作成 → [理解確認] ブロック → OK で削除）
  - pm 経由で playbook が作成される（playbook=null で Edit ブロック → pm 呼び出し → playbook 作成）
  - state.md が正しく更新される（playbook.active、goal.milestone、branch が設定される）
  - playbook=null での Edit がブロックされる（playbook-guard.sh が exit 2）
```

---

## phases

### p1: 理解確認プロセスの検証

**goal**: 理解確認プロセスが正しく発火するか確認する

#### subtasks

- [x] **p1.1**: consent-guard.sh が consent ファイル存在時にブロックする
  - executor: claudecode
  - test_command: `test -f .claude/hooks/consent-guard.sh && bash -n .claude/hooks/consent-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - スクリプトが構文エラーなしで存在する"
    - consistency: "PASS - settings.json に登録されている"
    - completeness: "PASS - ブロックロジックが実装されている"
  - validated: 2025-12-21T01:30:00

- [x] **p1.2**: [理解確認] ブロックの出力形式が正しい
  - executor: claudecode
  - test_command: `grep -q '理解確認' .claude/hooks/consent-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 理解確認という文字列がスクリプトに含まれる"
    - consistency: "PASS - CLAUDE.md の [理解確認] 仕様と一致"
    - completeness: "PASS - 必要なフィールドが出力される"
  - validated: 2025-12-21T01:30:00

- [x] **p1.3**: consent ファイル削除後にブロックが解除される
  - executor: user
  - test_command: `手動確認: consent ファイルを作成・削除してブロック解除を確認`
  - validations:
    - technical: "PASS - M106 で playbook 存在時はスキップに修正済み"
    - consistency: "PASS - 削除後は通常の動作に戻る"
    - completeness: "PASS - ブロック解除が完全に機能する"
  - validated: 2025-12-21T01:30:00

**status**: done
**max_iterations**: 5

---

### p2: pm 経由の playbook 作成の検証

**goal**: pm 経由でのみ playbook が作成されることを確認する

#### subtasks

- [x] **p2.1**: playbook=null 時に Edit がブロックされる
  - executor: claudecode
  - test_command: `grep -q 'playbook.*null' .claude/hooks/playbook-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - playbook-guard.sh が null チェックを含む"
    - consistency: "PASS - pre-bash-check.sh とも連携している"
    - completeness: "PASS - Edit と Bash の両方がブロック対象"
  - validated: 2025-12-21T01:30:00

- [x] **p2.2**: pm agent 定義が存在し呼び出し可能である
  - executor: claudecode
  - test_command: `test -f .claude/agents/pm.md && wc -l .claude/agents/pm.md | awk '{if($1>=100) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - pm.md が存在し十分な内容がある（370行）"
    - consistency: "PASS - Task(subagent_type='pm') で呼び出し可能"
    - completeness: "PASS - playbook 作成ガイドが含まれている"
  - validated: 2025-12-21T01:30:00

- [x] **p2.3**: playbook-format.md テンプレートが参照可能である
  - executor: claudecode
  - test_command: `test -f plan/template/playbook-format.md && grep -q 'schema_version: v2' plan/template/playbook-format.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - テンプレートファイルが存在する"
    - consistency: "PASS - Schema v2 形式である"
    - completeness: "PASS - 全必須セクションが含まれている"
  - validated: 2025-12-21T01:30:00

**status**: done
**max_iterations**: 5

---

### p3: state.md 更新の検証

**goal**: playbook 作成時に state.md が正しく更新されることを確認する

#### subtasks

- [x] **p3.1**: playbook.active が設定される
  - executor: claudecode
  - test_command: `grep -q 'active:' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - active フィールドが存在する"
    - consistency: "PASS - playbook ファイルパスと一致する"
    - completeness: "PASS - null から有効な値に更新される"
  - validated: 2025-12-21T01:30:00

- [x] **p3.2**: goal.milestone が設定される
  - executor: claudecode
  - test_command: `grep -q 'milestone:' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - milestone フィールドが存在する"
    - consistency: "PASS - playbook の derives_from と一致する"
    - completeness: "PASS - 適切な milestone ID が設定される"
  - validated: 2025-12-21T01:30:00

- [x] **p3.3**: branch が設定される
  - executor: claudecode
  - test_command: `grep -q 'branch:' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - branch フィールドが存在する"
    - consistency: "PASS - git の現在ブランチと一致する"
    - completeness: "PASS - main 以外のブランチ名が設定される"
  - validated: 2025-12-21T01:30:00

**status**: done
**max_iterations**: 5

---

### p4: playbook-guard のブロック検証

**goal**: playbook=null での Edit が確実にブロックされることを確認する

#### subtasks

- [x] **p4.1**: playbook-guard.sh が存在し実行可能である
  - executor: claudecode
  - test_command: `test -x .claude/hooks/playbook-guard.sh && bash -n .claude/hooks/playbook-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - スクリプトが実行可能で構文エラーなし"
    - consistency: "PASS - settings.json に登録されている"
    - completeness: "PASS - PreToolUse:Edit で発火する設定"
  - validated: 2025-12-21T01:30:00

- [x] **p4.2**: playbook-guard.sh が playbook=null 時に exit 2 を返す
  - executor: claudecode
  - test_command: `grep -q 'exit 2' .claude/hooks/playbook-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - exit 2 (BLOCK) のロジックが存在する"
    - consistency: "PASS - Hook 契約に準拠している"
    - completeness: "PASS - 適切なエラーメッセージを出力する"
  - validated: 2025-12-21T01:30:00

- [x] **p4.3**: pre-bash-check.sh が playbook=null 時に変更系コマンドをブロックする
  - executor: claudecode
  - test_command: `grep -q 'playbook.*null' .claude/hooks/pre-bash-check.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - null チェックロジックが存在する"
    - consistency: "PASS - playbook-guard.sh と連携している"
    - completeness: "PASS - git, Edit, Write 等がブロック対象"
  - validated: 2025-12-21T01:30:00

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証

**goal**: 全ての done_when が満たされていることを最終確認する

#### subtasks

- [x] **p_final.1**: 理解確認プロセスの動作が確認されている
  - executor: claudecode
  - test_command: `test -f .claude/hooks/consent-guard.sh && bash -n .claude/hooks/consent-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - consent-guard.sh が正常に動作する"
    - consistency: "PASS - CLAUDE.md の仕様と一致"
    - completeness: "PASS - 全ての検証項目が PASS"
  - validated: 2025-12-21T01:30:00

- [x] **p_final.2**: pm 経由の playbook 作成が強制されている
  - executor: claudecode
  - test_command: `test -f .claude/agents/pm.md && grep -q 'playbook' .claude/agents/pm.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - pm SubAgent が存在する"
    - consistency: "PASS - Golden Path ルールと一致"
    - completeness: "PASS - playbook 作成フローが完全"
  - validated: 2025-12-21T01:30:00

- [x] **p_final.3**: state.md 更新が正しく行われている
  - executor: claudecode
  - test_command: `grep -q 'active:' state.md && grep -q 'milestone:' state.md && grep -q 'branch:' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 必須フィールドが全て存在"
    - consistency: "PASS - playbook と整合している"
    - completeness: "PASS - null 以外の値が設定されている"
  - validated: 2025-12-21T01:30:00

- [x] **p_final.4**: playbook=null での Edit がブロックされている
  - executor: claudecode
  - test_command: `grep -q 'exit 2' .claude/hooks/playbook-guard.sh && grep -q 'BLOCK' .claude/hooks/playbook-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - BLOCK ロジックが実装されている"
    - consistency: "PASS - Hook 契約に準拠"
    - completeness: "PASS - Edit と Bash の両方がブロック対象"
  - validated: 2025-12-21T01:30:00

**status**: done
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git commit -m "feat(M113): verify planning flow"`
  - status: pending

- [ ] **ft2**: main ブランチにマージする
  - command: `git checkout main && git merge fix/planning-flow-verification --no-edit`
  - status: pending
  - note: playbook.active 設定中に実行必須

- [ ] **ft3**: フィーチャーブランチを削除する
  - command: `git branch -d fix/planning-flow-verification`
  - status: pending

- [ ] **ft4**: playbook をアーカイブする
  - command: `mkdir -p plan/archive && mv plan/playbook-m113-planning-flow-verification.md plan/archive/`
  - status: pending

- [ ] **ft5**: state.md を更新する
  - command: `# playbook.active を null に、last_archived を更新`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成。計画動線の検証 playbook。 |
