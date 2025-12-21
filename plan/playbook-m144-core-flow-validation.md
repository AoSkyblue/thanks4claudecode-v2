# playbook-m144-core-flow-validation.md

> **M144: コア動線機能検証**
>
> core-manifest.yaml の動線優先構造が実際に機能するかをユーザー承認で確認

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode-v2
branch: feat/m144-core-flow-validation
created: 2025-12-21
issue: null
derives_from: M143  # manifest-flow-first の検証
reviewed: false

user_prompt_original: |
  M144 コア動線機能検証
  各動線を1つずつテストし、ユーザーの目視確認・承認を得てから次へ進む
  p1: 計画動線テスト
  p2: 実行動線テスト
  p3: 検証動線テスト
  p4: 完了動線テスト
```

---

## goal

```yaml
summary: 4動線（計画・実行・検証・完了）が実際に機能することをユーザー承認で確認
done_when:
  - 計画動線がユーザー承認を得ている
  - 実行動線がユーザー承認を得ている
  - 検証動線がユーザー承認を得ている
  - 完了動線がユーザー承認を得ている
```

---

## phases

### p1: 計画動線テスト

**goal**: ユーザー要求から playbook 作成までの動線が機能することを確認

#### subtasks

- [ ] **p1.1**: pm が呼び出される条件が core-manifest.yaml に定義されている
  - executor: claudecode
  - test_command: `grep -q 'pm:' governance/core-manifest.yaml && echo PASS || echo FAIL`
  - validations:
    - technical: "grep コマンドが正常に実行できる"
    - consistency: "core-manifest.yaml の構造と一致"
    - completeness: "pm 定義が存在する"

- [ ] **p1.2**: playbook 作成フローが動作することをユーザーに説明し承認を得る
  - executor: user
  - test_command: `手動確認: ユーザーが「計画動線 OK」と承認`
  - validations:
    - technical: "説明が技術的に正確"
    - consistency: "core-manifest.yaml の定義と一致"
    - completeness: "計画動線の全ステップを説明"

**status**: pending
**max_iterations**: 3

---

### p2: 実行動線テスト

**goal**: playbook=null で Edit がブロックされ、playbook=active で Edit が通ることを確認

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: playbook-gate の定義が core-manifest.yaml に存在する
  - executor: claudecode
  - test_command: `grep -q 'playbook_gate\|playbook-gate' governance/core-manifest.yaml && echo PASS || echo FAIL`
  - validations:
    - technical: "grep コマンドが正常に実行できる"
    - consistency: "CLAUDE.md の Core Contract と整合"
    - completeness: "Guard 定義が存在する"

- [ ] **p2.2**: 実行動線の仕組みをユーザーに説明し承認を得る
  - executor: user
  - test_command: `手動確認: ユーザーが「実行動線 OK」と承認`
  - validations:
    - technical: "説明が技術的に正確"
    - consistency: "core-manifest.yaml の定義と一致"
    - completeness: "実行動線の全ステップを説明"

**status**: pending
**max_iterations**: 3

---

### p3: 検証動線テスト

**goal**: critic が呼ばれ PASS/FAIL が判定されることを確認

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: critic の定義が core-manifest.yaml に存在する
  - executor: claudecode
  - test_command: `grep -q 'critic:' governance/core-manifest.yaml && echo PASS || echo FAIL`
  - validations:
    - technical: "grep コマンドが正常に実行できる"
    - consistency: "agents/critic.md と整合"
    - completeness: "critic 定義が存在する"

- [ ] **p3.2**: 検証動線の仕組みをユーザーに説明し承認を得る
  - executor: user
  - test_command: `手動確認: ユーザーが「検証動線 OK」と承認`
  - validations:
    - technical: "説明が技術的に正確"
    - consistency: "core-manifest.yaml の定義と一致"
    - completeness: "検証動線の全ステップを説明"

**status**: pending
**max_iterations**: 3

---

### p4: 完了動線テスト

**goal**: playbook アーカイブと次タスク導出が機能することを確認

**depends_on**: [p3]

#### subtasks

- [ ] **p4.1**: アーカイブ処理の定義が core-manifest.yaml に存在する
  - executor: claudecode
  - test_command: `grep -q 'archive' governance/core-manifest.yaml && echo PASS || echo FAIL`
  - validations:
    - technical: "grep コマンドが正常に実行できる"
    - consistency: "archive-playbook.sh と整合"
    - completeness: "アーカイブ定義が存在する"

- [ ] **p4.2**: 完了動線の仕組みをユーザーに説明し承認を得る
  - executor: user
  - test_command: `手動確認: ユーザーが「完了動線 OK」と承認`
  - validations:
    - technical: "説明が技術的に正確"
    - consistency: "core-manifest.yaml の定義と一致"
    - completeness: "完了動線の全ステップを説明"

**status**: pending
**max_iterations**: 3

---

### p_final: 完了検証

**goal**: done_when の全項目が満たされていることを最終確認

**depends_on**: [p4]

#### subtasks

- [ ] **p_final.1**: 4動線全てがユーザー承認を得ている
  - executor: user
  - test_command: `手動確認: p1-p4 の全 user subtask が承認済み`
  - validations:
    - technical: "各 phase の承認記録が存在"
    - consistency: "playbook の status と一致"
    - completeness: "4動線全ての承認を確認"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

- [ ] **ft2**: state.md を更新する
  - command: `手動確認: playbook.active を更新`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
