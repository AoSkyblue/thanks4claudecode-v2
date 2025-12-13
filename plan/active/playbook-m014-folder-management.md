# playbook-m014-folder-management.md

## meta

```yaml
project: thanks4claudecode
branch: feat/folder-management
created: 2025-12-13
issue: null
derives_from: M014
reviewed: false
```

---

## goal

```yaml
summary: |
  フォルダ管理ルールを確立し、クリーンアップ機構を実装する。
  1. 全フォルダの役割を明確化（テンポラリ/永続）
  2. tmp/ フォルダを新設し、テンポラリファイルを統一配置
  3. 不要ファイルを .archive/ に移動
  4. playbook 完了時の自動クリーンアップ機構を実装
  5. フォルダ管理ルールをドキュメント化

done_when:
  - 不要ファイルが .archive/ に移動されている
  - tmp/ フォルダが新設され、.gitignore に登録されている
  - .claude/hooks/cleanup-hook.sh が実装されている
  - 全 playbook テンプレートに cleanup phase が追加されている
  - docs/folder-management.md が作成されている
  - project.md に参照が追加されている
```

---

## phases

```yaml
- id: p0
  name: "アーカイブ候補ファイルの整理"
  goal: |
    テンポラリ/不要ファイルをマッピングし、
    アーカイブ対象を明確化。その後 .archive/ に移動する。
  depends_on: []

  subtasks:
    - id: p0.1
      criterion: "アーカイブ対象ファイルのリストが作成されている"
      executor: claudecode
      test_command: "ls -la /tmp/archive-candidates.txt 2>/dev/null && echo PASS || echo FAIL"

    - id: p0.2
      criterion: "test/ フォルダが .archive/test-m012/ に移動されている"
      executor: claudecode
      test_command: "test -d .archive/test-m012 && ! test -d test && echo PASS || echo FAIL"

    - id: p0.3
      criterion: "docs/codex-*.md が .archive/docs/ に移動されている"
      executor: claudecode
      test_command: "! ls docs/codex-*.md 2>/dev/null && ls .archive/docs/codex-*.md 2>/dev/null >/dev/null && echo PASS || echo FAIL"

    - id: p0.4
      criterion: "docs/audit-*.md が .archive/docs/ に移動されている"
      executor: claudecode
      test_command: "! ls docs/audit-*.md 2>/dev/null && ls .archive/docs/audit-*.md 2>/dev/null >/dev/null && echo PASS || echo FAIL"

    - id: p0.5
      criterion: "docs/phase7-*.md が .archive/docs/ に移動されている"
      executor: claudecode
      test_command: "! ls docs/phase7-*.md 2>/dev/null && ls .archive/docs/phase7-*.md 2>/dev/null >/dev/null && echo PASS || echo FAIL"

    - id: p0.6
      criterion: "plan/archive/ フォルダが存在し、完了済み playbook が集約されている"
      executor: claudecode
      test_command: "test -d plan/archive && ls plan/archive/playbook-m*.md 2>/dev/null | grep -q . && echo PASS || echo FAIL"

  status: pending
  max_iterations: 5

- id: p1
  name: "tmp/ フォルダ新設と役割定義"
  goal: |
    テンポラリファイルの統一置き場 tmp/ を作成し、
    役割を明文化。.gitignore で永続化を防止。
  depends_on: [p0]

  subtasks:
    - id: p1.1
      criterion: "tmp/ ディレクトリが存在する"
      executor: claudecode
      test_command: "test -d tmp && echo PASS || echo FAIL"

    - id: p1.2
      criterion: "tmp/CLAUDE.md が存在し、フォルダ役割を記載している"
      executor: claudecode
      test_command: "test -f tmp/CLAUDE.md && grep -q 'テンポラリファイル' tmp/CLAUDE.md && echo PASS || echo FAIL"

    - id: p1.3
      criterion: "tmp/README.md が存在し、ファイル配置ルールを説明している"
      executor: claudecode
      test_command: "test -f tmp/README.md && grep -q 'テンポラリ' tmp/README.md && echo PASS || echo FAIL"

    - id: p1.4
      criterion: ".gitignore に tmp/\\* が登録されており、永続化が防止されている"
      executor: claudecode
      test_command: "grep -q '^tmp/\\*$' .gitignore && echo PASS || echo FAIL"

  status: pending
  max_iterations: 5

- id: p2
  name: "クリーンアップ機構の実装"
  goal: |
    playbook 完了時に自動的にテンポラリファイルを削除する
    Hook スクリプト（cleanup-hook.sh）を実装。
  depends_on: [p1]

  subtasks:
    - id: p2.1
      criterion: ".claude/hooks/cleanup-hook.sh が実装されている"
      executor: claudecode
      test_command: "test -f .claude/hooks/cleanup-hook.sh && echo PASS || echo FAIL"

    - id: p2.2
      criterion: "cleanup-hook.sh が .claude/settings.json に登録されている"
      executor: claudecode
      test_command: "grep -q 'cleanup-hook' .claude/settings.json && echo PASS || echo FAIL"

    - id: p2.3
      criterion: "cleanup-hook.sh が ShellCheck で警告なしに合格している"
      executor: claudecode
      test_command: "shellcheck .claude/hooks/cleanup-hook.sh && echo PASS || echo FAIL"

    - id: p2.4
      criterion: "playbook テンプレートに cleanup に関する記述が追加されている"
      executor: claudecode
      test_command: "grep -q 'cleanup\\|テンポラリ' plan/template/playbook-format.md && echo PASS || echo FAIL"

  status: pending
  max_iterations: 5

- id: p3
  name: "フォルダ管理ルールのドキュメント化"
  goal: |
    各フォルダの役割、テンポラリ/永続区分、削除タイミングを
    明文化した包括的なドキュメントを作成。
  depends_on: [p2]

  subtasks:
    - id: p3.1
      criterion: "docs/folder-management.md が存在する"
      executor: claudecode
      test_command: "test -f docs/folder-management.md && echo PASS || echo FAIL"

    - id: p3.2
      criterion: "docs/folder-management.md に全フォルダの役割が列挙されている（15項目以上）"
      executor: claudecode
      test_command: "grep -c '^| ' docs/folder-management.md | awk '{if($1>=15) print \"PASS\"; else print \"FAIL\"}'"

    - id: p3.3
      criterion: "docs/folder-management.md にテンポラリ/永続の判定基準が記載されている"
      executor: claudecode
      test_command: "grep -q 'テンポラリ' docs/folder-management.md && grep -q '永続' docs/folder-management.md && echo PASS || echo FAIL"

    - id: p3.4
      criterion: "docs/folder-management.md にクリーンアップタイミングが記載されている"
      executor: claudecode
      test_command: "grep -q 'クリーンアップ\\|削除' docs/folder-management.md && echo PASS || echo FAIL"

  status: pending
  max_iterations: 5

- id: p4
  name: "既存ドキュメントの整理と参照追加"
  goal: |
    CLAUDE.md、feature-map.md、project.md に参照を追加し、
    フォルダ管理ルールの重要性を明示。
  depends_on: [p3]

  subtasks:
    - id: p4.1
      criterion: "CLAUDE.md にフォルダ管理ルール参照が追加されている"
      executor: claudecode
      test_command: "grep -q 'folder-management' CLAUDE.md && echo PASS || echo FAIL"

    - id: p4.2
      criterion: "feature-map.md にクリーンアップ Hook が記載されている"
      executor: claudecode
      test_command: "grep -q 'cleanup' docs/feature-map.md && echo PASS || echo FAIL"

    - id: p4.3
      criterion: "project.md に tmp/ と archive の記載がある"
      executor: claudecode
      test_command: "grep -q 'tmp/' plan/project.md && grep -q 'archive' plan/project.md && echo PASS || echo FAIL"

    - id: p4.4
      criterion: "state.md に参照ファイルとして docs/folder-management.md が記載されている"
      executor: claudecode
      test_command: "grep -q 'folder-management' state.md && echo PASS || echo FAIL"

  status: pending
  max_iterations: 5

- id: p5
  name: "最終検証とクリーンアップ"
  goal: |
    全 Phase の done_criteria を検証。
    git status で削除と追加を確認。
  depends_on: [p4]

  subtasks:
    - id: p5.1
      criterion: "git status で削除されたファイルが表示されている"
      executor: claudecode
      test_command: "git status -s | grep -E '^\\s*D ' && echo PASS || echo FAIL"

    - id: p5.2
      criterion: ".archive/ フォルダが git の管理下にあり、ファイルが複数存在する"
      executor: claudecode
      test_command: "git ls-files .archive | wc -l | awk '{if($1>5) print \"PASS\"; else print \"FAIL\"}'"

    - id: p5.3
      criterion: "tmp/ が .gitignore に登録され、git は追跡していない"
      executor: claudecode
      test_command: "grep -q '^tmp/\\*$' .gitignore && ! git ls-files tmp 2>/dev/null | grep -q . && echo PASS || echo FAIL"

    - id: p5.4
      criterion: "cleanup-hook.sh が実際に動作することを確認している"
      executor: user
      test_command: "手動確認: cleanup-hook.sh をテスト実行し、テンポラリファイルが削除されることを確認"

  status: pending
  max_iterations: 5

status: pending
```

---

## notes

```yaml
context:
  - M013 完了後の直次タスク
  - 現在のテンポラリファイルが散在している状態を整理
  - 永続的なクリーンアップ機構を確立（手動不要）

design_decisions:
  - アーカイブ先: .archive/ に統一（既存 plan/archive/ と併用）
  - テンポラリ置き場: tmp/ を新設（永続化しない）
  - Hook 名: cleanup-hook.sh（archive-playbook.sh との連携）

risks:
  - Phase p0 でファイル移動が失敗する可能性
  - 誤削除防止のため dry-run で事前確認が必要
  - 他 Phase に依存するファイルの参照破損

mitigation:
  - .archive/ 移動前に git status を確認
  - 移動後に参照リンク（docs など）を更新
  - cleanup-hook.sh の dry-run オプション実装
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-13 | 初版作成。M014 derives_from 設定。5 Phase + cleanup 設計。 |
