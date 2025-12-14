# playbook-m020-archive-bugfix.md

> **archive-playbook.sh バグ修正 & 残存 playbook のアーカイブ**

---

## meta

```yaml
project: thanks4claudecode
branch: feat/m020-archive-bugfix
created: 2025-12-14
issue: null
derives_from: M020
reviewed: false
```

---

## goal

```yaml
summary: archive-playbook.sh のアーカイブ先バグを修正し、完了済み playbook を plan/archive/ に移動
done_when:
  - archive-playbook.sh の ARCHIVE_DIR が `plan/archive/` に修正されている
  - plan/active/ の完了済み playbook (M014, M015, M016) が移動されている
  - plan/archive/ に全ての playbook が存在する
  - git log に修正コミットが記録されている
```

---

## phases

### p0: 問題確認と修正計画

```yaml
id: p0
name: "問題確認と修正計画"
goal: "バグの詳細を確認し、修正内容を定義"

subtasks:
  - id: p0.1
    criterion: "archive-playbook.sh の ARCHIVE_DIR が `.archive/plan` に設定されていることを確認"
    executor: claudecode
    test_command: "grep -n 'ARCHIVE_DIR=' /Users/amano/Desktop/thanks4claudecode/.claude/hooks/archive-playbook.sh | grep -q '\\.archive/plan' && echo PASS || echo FAIL"

  - id: p0.2
    criterion: "plan/active/ ディレクトリに完了済み playbook (M014, M015, M016) が存在することを確認"
    executor: claudecode
    test_command: "ls -la /Users/amano/Desktop/thanks4claudecode/plan/active/ | grep -E 'playbook-m01[456]' | wc -l | awk '{if ($1 >= 3) print \"PASS\"; else print \"FAIL\"}'"

  - id: p0.3
    criterion: "plan/archive/ ディレクトリが存在すること"
    executor: claudecode
    test_command: "test -d /Users/amano/Desktop/thanks4claudecode/plan/archive && echo PASS || echo FAIL"

  - id: p0.4
    criterion: "各 playbook ファイルが完了しているか（全 phase が done）を確認"
    executor: claudecode
    test_command: "for file in /Users/amano/Desktop/thanks4claudecode/plan/active/playbook-m01[456]*.md; do [ -f \"$file\" ] && grep -c '^  status: done' \"$file\" > /tmp/done_count.txt && [ $(cat /tmp/done_count.txt) -gt 0 ] || exit 1; done && echo PASS || echo FAIL"

status: done
max_iterations: 5
```

### p1: archive-playbook.sh の修正

```yaml
id: p1
name: "archive-playbook.sh の ARCHIVE_DIR 修正"
goal: "バグを修正し、アーカイブ先を `.archive/plan` から `plan/archive/` に変更"
depends_on: [p0]

subtasks:
  - id: p1.1
    criterion: "archive-playbook.sh の 86行目の ARCHIVE_DIR が `plan/archive/` に修正されている"
    executor: claudecode
    test_command: "grep -n 'ARCHIVE_DIR=' /Users/amano/Desktop/thanks4claudecode/.claude/hooks/archive-playbook.sh | grep -q 'plan/archive' && echo PASS || echo FAIL"

  - id: p1.2
    criterion: "修正後のスクリプトが syntax チェックを通る"
    executor: claudecode
    test_command: "bash -n /Users/amano/Desktop/thanks4claudecode/.claude/hooks/archive-playbook.sh && echo PASS || echo FAIL"

  - id: p1.3
    criterion: "修正内容が git diff に反映されている"
    executor: claudecode
    test_command: "cd /Users/amano/Desktop/thanks4claudecode && git diff .claude/hooks/archive-playbook.sh | grep -q 'plan/archive' && echo PASS || echo FAIL"

status: done
max_iterations: 5
```

### p2: 残存 playbook の移動

```yaml
id: p2
name: "完了済み playbook の移動"
goal: "M014, M015, M016 の playbook を plan/active/ から plan/archive/ に移動"
depends_on: [p1]

subtasks:
  - id: p2.1
    criterion: "M014 playbook が plan/archive/ に移動されている"
    executor: claudecode
    test_command: "test -f /Users/amano/Desktop/thanks4claudecode/plan/archive/playbook-m014-folder-management.md && echo PASS || echo FAIL"

  - id: p2.2
    criterion: "M015 playbook が plan/archive/ に移動されている"
    executor: claudecode
    test_command: "test -f /Users/amano/Desktop/thanks4claudecode/plan/archive/playbook-m015-folder-test.md && echo PASS || echo FAIL"

  - id: p2.3
    criterion: "M016 playbook が plan/archive/ に移動されている"
    executor: claudecode
    test_command: "test -f /Users/amano/Desktop/thanks4claudecode/plan/archive/playbook-m016-release-preparation.md && echo PASS || echo FAIL"

  - id: p2.4
    criterion: "plan/active/ から対象 playbook が削除されている"
    executor: claudecode
    test_command: "ls -la /Users/amano/Desktop/thanks4claudecode/plan/active/ | grep -c 'playbook-m01[456]' | awk '{if ($1 == 0) print \"PASS\"; else print \"FAIL\"}'"

  - id: p2.5
    criterion: "git status に移動操作が記録されている"
    executor: claudecode
    test_command: "cd /Users/amano/Desktop/thanks4claudecode && git status | grep -E 'playbook-m01[456]' && echo PASS || echo FAIL"

status: done
max_iterations: 5
```

### p3: 動作確認とコミット

```yaml
id: p3
name: "修正内容の検証とコミット"
goal: "スクリプト修正と playbook 移動を確認し、git コミット"
depends_on: [p2]

subtasks:
  - id: p3.1
    criterion: "plan/archive/ ディレクトリにアーカイブされた playbook が 3 個 以上存在する"
    executor: claudecode
    test_command: "ls -1 /Users/amano/Desktop/thanks4claudecode/plan/archive/playbook-*.md 2>/dev/null | wc -l | awk '{if ($1 >= 3) print \"PASS\"; else print \"FAIL\"}'"

  - id: p3.2
    criterion: "plan/active/ ディレクトリに playbook-m01[456]*.md が存在しない（移動完了）"
    executor: claudecode
    test_command: "test $(ls -1 /Users/amano/Desktop/thanks4claudecode/plan/active/playbook-m01[456]*.md 2>/dev/null | wc -l) -eq 0 && echo PASS || echo FAIL"

  - id: p3.3
    criterion: "git log に M020 関連のコミットが記録されている"
    executor: claudecode
    test_command: "cd /Users/amano/Desktop/thanks4claudecode && git log --oneline | grep -i 'archive\\|m020' | head -1 && echo PASS || echo FAIL"

  - id: p3.4
    criterion: "state.md の playbook.active が null に更新されている（task 完了後）"
    executor: user
    test_command: "手動確認: state.md の playbook.active セクションが null またはコメントアウトされていること"

status: done
max_iterations: 5
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-14 | M020 playbook 初版作成 |
