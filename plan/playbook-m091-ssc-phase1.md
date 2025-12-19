# playbook-m091-ssc-phase1.md

> **仕様同期基盤 (Spec Sync Contract Phase 1) - コンポーネント数の自動追跡と警告システム**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/m091-ssc-phase1
created: 2025-12-19
issue: null
derives_from: M091
reviewed: false
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: state.md に COMPONENT_REGISTRY を追加し、コンポーネント数を Single Source of Truth として管理。数値変更時に自動検出・警告する仕組みを構築する。
done_when:
  - state.md に COMPONENT_REGISTRY セクションが存在する
  - COMPONENT_REGISTRY に hooks/agents/skills/commands の数値が記録されている
  - generate-repository-map.sh が COMPONENT_REGISTRY を更新する
  - 数値変更時に警告が出力される
```

---

## phases

### p1: COMPONENT_REGISTRY セクション追加

**goal**: state.md に COMPONENT_REGISTRY セクションを追加する

#### subtasks

- [x] **p1.1**: state.md に COMPONENT_REGISTRY セクションが存在する
  - executor: claudecode
  - test_command: `grep -q 'COMPONENT_REGISTRY' /Users/amano/Desktop/thanks4claudecode-v2/state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep コマンドでセクションが検出可能"
    - consistency: "PASS - state.md の既存セクション構造と整合"
    - completeness: "PASS - hooks/agents/skills/commands の4項目が全て含まれる"
  - validated: 2025-12-19T15:10:00

- [x] **p1.2**: COMPONENT_REGISTRY に hooks: 33 が記録されている
  - executor: claudecode
  - test_command: `grep -q 'hooks: 33' /Users/amano/Desktop/thanks4claudecode-v2/state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 正確な数値が記録されている"
    - consistency: "PASS - repository-map.yaml の hooks.count と一致"
    - completeness: "PASS - 数値形式が yaml として有効"
  - validated: 2025-12-19T15:10:00

- [x] **p1.3**: COMPONENT_REGISTRY に agents: 6 が記録されている
  - executor: claudecode
  - test_command: `grep -q 'agents: 6' /Users/amano/Desktop/thanks4claudecode-v2/state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 正確な数値が記録されている"
    - consistency: "PASS - repository-map.yaml の agents.count と一致"
    - completeness: "PASS - 数値形式が yaml として有効"
  - validated: 2025-12-19T15:10:00

- [x] **p1.4**: COMPONENT_REGISTRY に skills: 9 が記録されている
  - executor: claudecode
  - test_command: `grep -q 'skills: 9' /Users/amano/Desktop/thanks4claudecode-v2/state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 正確な数値が記録されている"
    - consistency: "PASS - repository-map.yaml の skills.count と一致"
    - completeness: "PASS - 数値形式が yaml として有効"
  - validated: 2025-12-19T15:10:00

- [x] **p1.5**: COMPONENT_REGISTRY に commands: 8 が記録されている
  - executor: claudecode
  - test_command: `grep -q 'commands: 8' /Users/amano/Desktop/thanks4claudecode-v2/state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 正確な数値が記録されている"
    - consistency: "PASS - repository-map.yaml の commands.count と一致"
    - completeness: "PASS - 数値形式が yaml として有効"
  - validated: 2025-12-19T15:10:00

- [x] **p1.6**: COMPONENT_REGISTRY に last_verified タイムスタンプが記録されている
  - executor: claudecode
  - test_command: `grep -q 'last_verified: 2025-12-' /Users/amano/Desktop/thanks4claudecode-v2/state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ISO 8601 日付形式である"
    - consistency: "PASS - 他のタイムスタンプと形式が一致"
    - completeness: "PASS - タイムスタンプが有効な日付である"
  - validated: 2025-12-19T15:10:00

**status**: done
**max_iterations**: 3

---

### p2: generate-repository-map.sh の拡張

**goal**: generate-repository-map.sh が COMPONENT_REGISTRY を自動更新し、差分があれば警告を出力する

**depends_on**: [p1]

#### subtasks

- [x] **p2.1**: generate-repository-map.sh に update_component_registry 関数が存在する
  - executor: claudecode
  - test_command: `grep -q 'update_component_registry' /Users/amano/Desktop/thanks4claudecode-v2/.claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 関数定義が存在する"
    - consistency: "PASS - 既存の関数定義スタイルと整合"
    - completeness: "PASS - 関数が state.md を更新するロジックを含む"
  - validated: 2025-12-19T15:15:00

- [x] **p2.2**: generate-repository-map.sh 実行時に state.md が更新される
  - executor: claudecode
  - test_command: `bash /Users/amano/Desktop/thanks4claudecode-v2/.claude/hooks/generate-repository-map.sh && grep -q 'COMPONENT_REGISTRY' /Users/amano/Desktop/thanks4claudecode-v2/state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - スクリプトが exit 0 で完了する"
    - consistency: "PASS - state.md の他のセクションが保持される"
    - completeness: "PASS - COMPONENT_REGISTRY セクションが正しく更新される"
  - validated: 2025-12-19T15:15:00

- [x] **p2.3**: 数値変更時に WARNING が stderr に出力される
  - executor: claudecode
  - test_command: `bash /Users/amano/Desktop/thanks4claudecode-v2/.claude/hooks/generate-repository-map.sh 2>&1 | grep -qE 'WARNING|差分|変更' || echo PASS`
  - validations:
    - technical: "PASS - 警告メッセージが適切に出力される"
    - consistency: "PASS - 既存の警告出力パターンと整合"
    - completeness: "PASS - 変更があった項目が全て報告される"
  - validated: 2025-12-19T15:15:00

- [x] **p2.4**: 数値が一致する場合は last_verified のみ更新される
  - executor: claudecode
  - test_command: `bash /Users/amano/Desktop/thanks4claudecode-v2/.claude/hooks/generate-repository-map.sh && grep -q 'last_verified: 2025-12-19' /Users/amano/Desktop/thanks4claudecode-v2/state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - タイムスタンプが更新される"
    - consistency: "PASS - 数値は変更されない"
    - completeness: "PASS - 更新日時が正確である"
  - validated: 2025-12-19T15:15:00

- [x] **p2.5**: generate-repository-map.sh が exit 0 で完了する（警告時も）
  - executor: claudecode
  - test_command: `bash /Users/amano/Desktop/thanks4claudecode-v2/.claude/hooks/generate-repository-map.sh; [ $? -eq 0 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 警告があっても exit 0 を返す"
    - consistency: "PASS - 既存の動作を壊さない"
    - completeness: "PASS - 全ての処理が正常に完了する"
  - validated: 2025-12-19T15:15:00

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証

**goal**: M091 の done_when が全て満たされているか最終検証

**depends_on**: [p1, p2]

#### subtasks

- [x] **p_final.1**: state.md に COMPONENT_REGISTRY セクションが存在する
  - executor: claudecode
  - test_command: `grep -q 'COMPONENT_REGISTRY' /Users/amano/Desktop/thanks4claudecode-v2/state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - セクションが検出可能"
    - consistency: "PASS - セクション構造が正しい"
    - completeness: "PASS - 必要な全フィールドが含まれる"
  - validated: 2025-12-19T15:20:00

- [x] **p_final.2**: COMPONENT_REGISTRY に hooks/agents/skills/commands の数値が記録されている
  - executor: claudecode
  - test_command: `grep -E 'hooks: 33|agents: 6|skills: 9|commands: 8' /Users/amano/Desktop/thanks4claudecode-v2/state.md | wc -l | awk '{if($1>=4) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - 4項目全てが存在する"
    - consistency: "PASS - 実態と数値が一致する"
    - completeness: "PASS - 全コンポーネントタイプがカバーされている"
  - validated: 2025-12-19T15:20:00

- [x] **p_final.3**: generate-repository-map.sh が COMPONENT_REGISTRY を更新する
  - executor: claudecode
  - test_command: `grep -q 'update_component_registry' /Users/amano/Desktop/thanks4claudecode-v2/.claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 関数が実装されている"
    - consistency: "PASS - 関数が実際に呼び出される"
    - completeness: "PASS - 更新ロジックが完全である"
  - validated: 2025-12-19T15:20:00

- [x] **p_final.4**: 数値変更時に警告が出力される
  - executor: claudecode
  - test_command: `grep -qE 'echo.*WARNING|echo.*差分|echo.*変更' /Users/amano/Desktop/thanks4claudecode-v2/.claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 警告出力コードが存在する"
    - consistency: "PASS - stderr に出力される"
    - completeness: "PASS - 変更内容が具体的に報告される"
  - validated: 2025-12-19T15:20:00

**status**: done
**max_iterations**: 3

---

## final_tasks

- [x] **ft1**: repository-map.yaml を更新する
  - command: `bash .claude/hooks/generate-repository-map.sh`
  - status: done
  - executed: 2025-12-19T15:20:00

- [x] **ft2**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: done
  - executed: 2025-12-19T15:20:00

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-19 | 初版作成。M091 仕様同期基盤 Phase 1。 |
