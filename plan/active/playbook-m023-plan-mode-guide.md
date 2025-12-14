# playbook-m023-plan-mode-guide.md

> **Plan mode と Named Sessions の活用ガイド**

---

## meta

```yaml
project: thanks4claudecode
branch: feat/m023-plan-mode-guide
created: 2025-12-14
issue: null
derives_from: M023
reviewed: false
```

---

## goal

```yaml
summary: Plan mode（think/ultrathink）と Named Sessions（/rename, /resume）をワークフローに統合
done_when:
  - CLAUDE.md に Plan mode 使用ガイドラインが追加されている
  - setup/playbook-setup.md に Plan mode 活用指示が追加されている
  - Named Sessions の使用ガイドが docs/session-management.md に作成されている
  - /rename、/resume コマンドの活用方法がドキュメント化されている
```

---

## phases

```yaml
- id: p0
  name: Plan mode 使用ガイドライン追加
  goal: CLAUDE.md に Plan mode（think/ultrathink）の使用基準を追加

  subtasks:
    - id: p0.1
      criterion: "CLAUDE.md に PLAN_MODE セクションが存在する"
      executor: claudecode
      test_command: "grep -q 'PLAN_MODE' CLAUDE.md && echo PASS || echo FAIL"

    - id: p0.2
      criterion: "think と ultrathink の使い分けが明記されている"
      executor: claudecode
      test_command: "grep -q 'think' CLAUDE.md && grep -q 'ultrathink' CLAUDE.md && echo PASS || echo FAIL"

    - id: p0.3
      criterion: "Plan mode を使うべき場面が3つ以上列挙されている"
      executor: claudecode
      test_command: "grep -A 20 'PLAN_MODE' CLAUDE.md | grep -c '- ' | awk '{if($1>=3) print \"PASS\"; else print \"FAIL\"}'"

  status: done
  max_iterations: 5

- id: p1
  name: setup への Plan mode 統合
  goal: setup/playbook-setup.md に Plan mode の活用指示を追加
  depends_on: [p0]

  subtasks:
    - id: p1.1
      criterion: "setup/playbook-setup.md に Plan mode の推奨が記載されている"
      executor: claudecode
      test_command: "grep -qi 'plan mode\\|ultrathink\\|think' setup/playbook-setup.md && echo PASS || echo FAIL"

    - id: p1.2
      criterion: "複雑な要件定義時に ultrathink を使う指示がある"
      executor: claudecode
      test_command: "grep -qi 'ultrathink' setup/playbook-setup.md && echo PASS || echo FAIL"

  status: done
  max_iterations: 5

- id: p2
  name: Named Sessions ガイド作成
  goal: docs/session-management.md を作成し、/rename と /resume の使用方法を記載
  depends_on: [p1]

  subtasks:
    - id: p2.1
      criterion: "docs/session-management.md が存在する"
      executor: claudecode
      test_command: "test -f docs/session-management.md && echo PASS || echo FAIL"

    - id: p2.2
      criterion: "/rename コマンドの使用方法が記載されている"
      executor: claudecode
      test_command: "grep -q '/rename' docs/session-management.md && echo PASS || echo FAIL"

    - id: p2.3
      criterion: "/resume コマンドの使用方法が記載されている"
      executor: claudecode
      test_command: "grep -q '/resume' docs/session-management.md && echo PASS || echo FAIL"

    - id: p2.4
      criterion: "state.md との連携方法が記載されている"
      executor: claudecode
      test_command: "grep -q 'state.md' docs/session-management.md && echo PASS || echo FAIL"

  status: done
  max_iterations: 5
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-14 | 初版作成 |
