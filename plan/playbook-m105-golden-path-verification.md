# playbook-m105-golden-path-verification.md

> **動線単位の動作テスト - 棚卸しと検証**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/layer-architecture
created: 2025-12-20
derives_from: M105
reviewed: false
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: 全40コンポーネントを動線単位で総点検し、何が動いて何が動かないかを明らかにする
done_when:
  - check.md に旧仕様が記録されている
  - project.md の M105 が check.md と整合している
  - 計画動線（6個）の動作確認が完了している
  - 実行動線（11個）の動作確認が完了している
  - 検証動線（6個）の動作確認が完了している
  - 完了動線（8個）の動作確認が完了している
  - 共通基盤（6個）の動作確認が完了している
  - 横断的整合性（3個）の動作確認が完了している
  - 動作不良コンポーネントが特定され修正方針が決まっている
```

---

## phases

### p1: ドキュメント整合

**goal**: check.md と project.md を整合させる

#### subtasks

- [ ] **p1.1**: check.md に旧仕様セクションを追記
  - executor: claudecode
  - validations:
    - technical: "旧仕様フローが記載されている"
    - consistency: "既存セクションと整合"
    - completeness: "線形フロー全体が含まれている"

- [ ] **p1.2**: project.md の M105 テスト対象を check.md と整合
  - executor: claudecode
  - validations:
    - technical: "YAML 構文が正しい"
    - consistency: "6カテゴリ40コンポーネントが一致"
    - completeness: "全コンポーネントが含まれている"

**status**: in_progress
**max_iterations**: 2

---

### p2: 計画動線テスト

**goal**: 計画動線の6コンポーネントの動作確認

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: /task-start 動作確認
- [ ] **p2.2**: playbook-init 動作確認
- [ ] **p2.3**: pm SubAgent 動作確認
- [ ] **p2.4**: state Skill 動作確認
- [ ] **p2.5**: plan-management Skill 動作確認
- [ ] **p2.6**: prompt-guard Hook 動作確認

**status**: pending
**max_iterations**: 3

---

### p3: 実行動線テスト

**goal**: 実行動線の11コンポーネントの動作確認

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: init-guard 動作確認
- [ ] **p3.2**: playbook-guard 動作確認
- [ ] **p3.3**: subtask-guard 動作確認（WARN モード問題）
- [ ] **p3.4**: scope-guard 動作確認
- [ ] **p3.5**: check-protected-edit 動作確認
- [ ] **p3.6**: pre-bash-check 動作確認
- [ ] **p3.7**: consent-guard 動作確認（デッドロック問題）
- [ ] **p3.8**: executor-guard 動作確認
- [ ] **p3.9**: check-main-branch 動作確認
- [ ] **p3.10**: lint-checker Skill 動作確認
- [ ] **p3.11**: test-runner Skill 動作確認

**status**: pending
**max_iterations**: 5

---

### p4: 検証動線テスト

**goal**: 検証動線の6コンポーネントの動作確認

**depends_on**: [p3]

#### subtasks

- [ ] **p4.1**: /crit Command 動作確認
- [ ] **p4.2**: /test Command 動作確認
- [ ] **p4.3**: /lint Command 動作確認
- [ ] **p4.4**: critic SubAgent 動作確認
- [ ] **p4.5**: reviewer SubAgent 動作確認
- [ ] **p4.6**: critic-guard 動作確認（playbook 未対応問題）

**status**: pending
**max_iterations**: 3

---

### p5: 完了動線テスト

**goal**: 完了動線の8コンポーネントの動作確認

**depends_on**: [p4]

#### subtasks

- [ ] **p5.1**: /rollback Command 動作確認
- [ ] **p5.2**: /state-rollback Command 動作確認
- [ ] **p5.3**: /focus Command 動作確認
- [ ] **p5.4**: archive-playbook Hook 動作確認
- [ ] **p5.5**: cleanup-hook 動作確認
- [ ] **p5.6**: create-pr-hook 動作確認
- [ ] **p5.7**: post-loop Skill 動作確認
- [ ] **p5.8**: context-management Skill 動作確認

**status**: pending
**max_iterations**: 3

---

### p6: 共通基盤テスト

**goal**: 共通基盤の6コンポーネントの動作確認

**depends_on**: [p5]

#### subtasks

- [ ] **p6.1**: session-start Hook 動作確認
- [ ] **p6.2**: session-end Hook 動作確認
- [ ] **p6.3**: pre-compact Hook 動作確認
- [ ] **p6.4**: stop-summary Hook 動作確認
- [ ] **p6.5**: log-subagent Hook 動作確認
- [ ] **p6.6**: consent-process Skill 動作確認

**status**: pending
**max_iterations**: 3

---

### p7: 横断的整合性テスト

**goal**: 横断的整合性の3コンポーネントの動作確認

**depends_on**: [p6]

#### subtasks

- [ ] **p7.1**: check-coherence Hook 動作確認
- [ ] **p7.2**: depends-check Hook 動作確認
- [ ] **p7.3**: lint-check Hook 動作確認

**status**: pending
**max_iterations**: 2

---

### p_final: 総括

**goal**: 動作不良の一覧と修正方針をまとめる

**depends_on**: [p7]

#### subtasks

- [ ] **p_final.1**: 動作不良コンポーネントの一覧作成
- [ ] **p_final.2**: 修正方針の決定
- [ ] **p_final.3**: 次マイルストーン（修正実装）の定義

**status**: pending
**max_iterations**: 2

---

## notes

- Layer 実装は不要（棚卸しと検証が目的）
- 既知の問題: subtask-guard WARN モード、critic-guard playbook 未対応、consent-guard デッドロック
