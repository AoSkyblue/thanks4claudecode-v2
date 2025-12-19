# playbook-m086-create-pr-hook-recovery.md

> **create-pr-hook.sh を復旧し、CodeRabbit 連携を再開**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/m086-create-pr-hook-recovery
created: 2025-12-19
issue: null
derives_from: M086
reviewed: true
```

---

## goal

```yaml
summary: |
  create-pr-hook.sh に gh コマンドの存在チェックを追加し、
  M086 の done_when を全て満たす。

done_when:
  - create-pr-hook.sh が SKIP 時に理由を stderr に出す
  - gh コマンド不存在時に WARN を出力
  - PR 作成成功時に PR URL をログに出力
```

---

## phases

### p1: 修正

**goal**: create-pr-hook.sh に gh コマンドチェックを追加

#### subtasks

- [ ] **p1.1**: create-pr-hook.sh の前提条件チェックセクションに gh コマンド存在チェックが追加されている
  - executor: claudecode
  - test_command: `grep -q 'command -v gh' .claude/hooks/create-pr-hook.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "gh コマンドチェックが bash -n でエラーなく実行できる"
    - consistency: "create-pr.sh の gh チェックと同様のパターンを使用"
    - completeness: "チェック失敗時に WARN を stderr に出力し exit 0 で継続"

- [ ] **p1.2**: gh コマンド不存在時に WARN メッセージが stderr に出力される
  - executor: claudecode
  - test_command: `grep -q '\[WARN\].*gh' .claude/hooks/create-pr-hook.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "WARN メッセージが適切に出力される"
    - consistency: "他の SKIP/WARN メッセージと同じフォーマット"
    - completeness: "gh インストール方法も案内する"

**status**: pending
**max_iterations**: 3

---

### p_final: 完了検証

**goal**: M086 の done_when が全て満たされているか最終検証

**depends_on**: [p1]

#### subtasks

- [ ] **p_final.1**: create-pr-hook.sh が SKIP 時に理由を stderr に出す
  - executor: claudecode
  - test_command: `grep -cE '\[SKIP\].*:' .claude/hooks/create-pr-hook.sh | awk '{if($1>=6) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "全 SKIP ケースで理由が出力される"
    - consistency: "M082 の Hook 契約に準拠"
    - completeness: "既存の SKIP メッセージが残っている"

- [ ] **p_final.2**: gh コマンド不存在時に WARN を出力する
  - executor: claudecode
  - test_command: `grep -q 'command -v gh' .claude/hooks/create-pr-hook.sh && grep -q '\[WARN\]' .claude/hooks/create-pr-hook.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "gh チェックロジックが存在する"
    - consistency: "exit 0 で継続する（ブロックしない）"
    - completeness: "WARN メッセージにインストール方法が含まれる"

- [ ] **p_final.3**: PR 作成成功時に PR URL をログに出力する
  - executor: claudecode
  - test_command: `grep -q 'PR_URL\|pr.*url' .claude/hooks/create-pr.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "create-pr.sh が PR URL を出力する"
    - consistency: "create-pr-hook.sh は create-pr.sh を呼び出すため、URL 出力はそちらで行う"
    - completeness: "line 245 の echo で URL が出力される"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: repository-map.yaml を更新する
  - command: `bash .claude/hooks/generate-repository-map.sh`
  - status: pending

- [ ] **ft2**: tmp/ 内の一時ファイルを削除する
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true`
  - status: pending

- [ ] **ft3**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-19 | 初版作成。M086 対応。 |
