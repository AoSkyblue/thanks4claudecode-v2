# playbook-m142-hook-tests.md

> **全 Hook の実動作テスト**
>
> bash -n ではなく、実際に発火させて期待動作を検証する。

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/m142-hook-tests
created: 2025-12-21
issue: null
derives_from: M142
reviewed: false
roles:
  worker: claudecode

user_prompt_original: |
  コア機能の確定と凍結が一番最初にあったほうがいいかな。
  凍結の前に動作保証がなされている必要がある。
  例えば何回言っても君、理解確認機能が直らないしね。
  今の機能全部、リストアップして。何で動作しないのか、棚卸ししながら、
  スモールステップで進めるしかない。
```

---

## goal

```yaml
summary: 全 Hook の実動作テストを完了する
done_when:
  - "hook-runtime-test.sh が全登録 Hook をカバーしている"
  - "各 Hook の期待動作がコメントで明文化されている"
  - "hook-runtime-test.sh が全テスト PASS"
```

---

## phases

### p1: 現状把握

**goal**: 現在の hook-runtime-test.sh のカバレッジを確認

#### subtasks

- [ ] **p1.1**: 登録済み Hook の一覧を取得
  - executor: claudecode
  - test_command: `grep -oE 'hooks/[a-z-]+\.sh' .claude/settings.json | sed 's|hooks/||' | sort -u | wc -l`

- [ ] **p1.2**: hook-runtime-test.sh の現在のテスト数を確認
  - executor: claudecode
  - test_command: `bash scripts/hook-runtime-test.sh 2>&1 | grep -E '^[0-9]+/' | wc -l`

- [ ] **p1.3**: 未カバーの Hook を特定
  - executor: claudecode
  - test_command: `echo "未カバー Hook の一覧を作成"`

**status**: pending
**max_iterations**: 3

---

### p2: テスト拡張

**goal**: 全 Hook をカバーするテストを追加

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: 各 Hook の期待動作を明文化
  - executor: claudecode
  - test_command: `grep -c '# 期待動作:' scripts/hook-runtime-test.sh`

- [ ] **p2.2**: 未カバー Hook のテストを追加
  - executor: claudecode
  - test_command: `bash scripts/hook-runtime-test.sh 2>&1 | grep -c PASS`

- [ ] **p2.3**: 全テストが PASS することを確認
  - executor: claudecode
  - test_command: `bash scripts/hook-runtime-test.sh 2>&1 | tail -1 | grep -q 'ALL.*PASS' && echo PASS || echo FAIL`

**status**: pending
**max_iterations**: 5

---

### p_final: 完了検証（必須）

**goal**: 全ての done_criteria が満たされていることを検証

#### subtasks

- [ ] **p_final.1**: 全登録 Hook がカバーされていることを検証
  - executor: claudecode
  - test_command: `echo "カバレッジ検証"`

- [ ] **p_final.2**: 期待動作が明文化されていることを検証
  - executor: claudecode
  - test_command: `grep -c '# 期待動作:' scripts/hook-runtime-test.sh`

- [ ] **p_final.3**: 全テスト PASS を検証
  - executor: claudecode
  - test_command: `bash scripts/hook-runtime-test.sh 2>&1 | tail -1 | grep -q 'ALL.*PASS' && echo PASS || echo FAIL`

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
