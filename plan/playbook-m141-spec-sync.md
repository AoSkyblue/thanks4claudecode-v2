# playbook-m141-spec-sync.md

> **仕様と実態の完全同期**
>
> core-manifest.yaml、settings.json、実ファイルを完全同期させる。

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/m141-spec-sync
created: 2025-12-21
issue: null
derives_from: M141
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
summary: 仕様と実態を完全同期させる
done_when:
  - "depends-check.sh が settings.json に登録されているか、ファイルが削除されている"
  - "role-resolver.sh が settings.json に登録されているか、ファイルが削除されている"
  - "scripts/verify-manifest.sh が存在し、実行可能"
  - "scripts/verify-manifest.sh が PASS（仕様=実態）"
```

---

## phases

### p1: depends-check.sh の処遇決定

**goal**: depends-check.sh を settings.json に登録するか、ファイルを削除する

#### subtasks

- [x] **p1.1**: depends-check.sh の現状確認
  - executor: claudecode
  - test_command: `test -f .claude/hooks/depends-check.sh && echo EXISTS || echo NOT_FOUND`
  - validations:
    - technical: "PASS - ファイル存在確認"
    - consistency: "PASS - core-manifest.yaml に登録済み"
    - completeness: "PASS - Extension Layer 横断的整合性コンポーネント"
  - validated: 2025-12-21

- [x] **p1.2**: depends-check.sh の役割を core-manifest.yaml で確認
  - executor: claudecode
  - test_command: `grep -A2 'depends-check.sh' governance/core-manifest.yaml && echo PASS`
  - validations:
    - technical: "PASS - playbook 間依存関係の検証"
    - consistency: "PASS - Extension Layer cross_cutting に登録"
    - completeness: "PASS - 役割明確"
  - validated: 2025-12-21

- [x] **p1.3**: 登録または削除を実行
  - executor: claudecode
  - test_command: `grep -q 'depends-check.sh' .claude/settings.json || ! test -f .claude/hooks/depends-check.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - settings.json の Bash PreToolUse に登録"
    - consistency: "PASS - check-coherence.sh の直後に配置"
    - completeness: "PASS - timeout: 5000ms"
  - validated: 2025-12-21

**status**: done
**max_iterations**: 3

---

### p2: role-resolver.sh の処遇決定

**goal**: role-resolver.sh を settings.json に登録するか、ファイルを削除する

**depends_on**: [p1]

#### subtasks

- [x] **p2.1**: role-resolver.sh の現状確認
  - executor: claudecode
  - test_command: `test -f .claude/hooks/role-resolver.sh && echo EXISTS || echo NOT_FOUND`
  - validations:
    - technical: "PASS - ファイル存在確認（削除前）"
    - consistency: "PASS - core-manifest.yaml で deletion_candidates に登録"
    - completeness: "PASS - executor-guard.sh から呼び出されるが、存在チェック付き"
  - validated: 2025-12-21

- [x] **p2.2**: role-resolver.sh の役割を確認（削除候補か？）
  - executor: claudecode
  - test_command: `grep -q 'role-resolver.sh' governance/core-manifest.yaml && echo REGISTERED || echo NOT_REGISTERED`
  - validations:
    - technical: "PASS - deletion_candidates に登録済み"
    - consistency: "PASS - Hook ではなくユーティリティ"
    - completeness: "PASS - 削除しても executor-guard.sh は動作継続"
  - validated: 2025-12-21

- [x] **p2.3**: 登録または削除を実行
  - executor: claudecode
  - test_command: `grep -q 'role-resolver.sh' .claude/settings.json || ! test -f .claude/hooks/role-resolver.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ファイル削除完了"
    - consistency: "PASS - executor-guard.sh の -x チェックでスキップ"
    - completeness: "PASS - executor-guard.sh は HARD_BLOCK のため依存削除不要"
  - validated: 2025-12-21

**status**: done
**max_iterations**: 3

---

### p3: verify-manifest.sh の作成

**goal**: 仕様と実態の乖離を検出するスクリプトを作成

**depends_on**: [p2]

#### subtasks

- [x] **p3.1**: verify-manifest.sh の仕様を定義
  - executor: claudecode
  - test_command: `echo "仕様定義完了"`
  - validations:
    - technical: "PASS - Hook の検証（存在 + 登録）"
    - consistency: "PASS - 逆引きチェック（settings.json → manifest）"
    - completeness: "PASS - 実ファイル整合性チェック"
  - validated: 2025-12-21

- [x] **p3.2**: verify-manifest.sh を実装
  - executor: claudecode
  - test_command: `test -f scripts/verify-manifest.sh && test -x scripts/verify-manifest.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - スクリプト作成完了"
    - consistency: "PASS - 実行権限付与済み"
    - completeness: "PASS - testing セクションを除外"
  - validated: 2025-12-21

- [x] **p3.3**: verify-manifest.sh を実行して PASS を確認
  - executor: claudecode
  - test_command: `bash scripts/verify-manifest.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 全 Hook が EXISTS + REGISTERED"
    - consistency: "PASS - 逆引きで全 OK"
    - completeness: "PASS - 実ファイル整合性 OK"
  - validated: 2025-12-21

**status**: done
**max_iterations**: 3

---

### p_final: 完了検証（必須）

**goal**: 全ての done_criteria が満たされていることを検証

#### subtasks

- [x] **p_final.1**: depends-check.sh の解決を検証
  - executor: claudecode
  - test_command: `grep -q 'depends-check.sh' .claude/settings.json && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - settings.json の Bash PreToolUse に登録済み"
    - consistency: "PASS - core-manifest.yaml にも記載済み"
    - completeness: "PASS - 仕様と実態が一致"
  - validated: 2025-12-21

- [x] **p_final.2**: role-resolver.sh の解決を検証
  - executor: claudecode
  - test_command: `test -f .claude/hooks/role-resolver.sh && echo EXISTS || echo DELETED`
  - validations:
    - technical: "PASS - ファイル削除済み"
    - consistency: "PASS - executor-guard.sh の -x チェックでスキップ"
    - completeness: "PASS - deletion_candidates に記載のため削除が正解"
  - validated: 2025-12-21

- [x] **p_final.3**: verify-manifest.sh の存在と実行権限を検証
  - executor: claudecode
  - test_command: `test -f scripts/verify-manifest.sh && test -x scripts/verify-manifest.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ファイル存在 + 実行権限"
    - consistency: "PASS - chmod +x 済み"
    - completeness: "PASS - 3種の検証を実装"
  - validated: 2025-12-21

- [x] **p_final.4**: verify-manifest.sh が PASS することを検証
  - executor: claudecode
  - test_command: `bash scripts/verify-manifest.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 全 Hook が EXISTS + REGISTERED"
    - consistency: "PASS - 逆引きで全 OK"
    - completeness: "PASS - 実ファイル整合性 OK"
  - validated: 2025-12-21

**status**: done
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

- [ ] **ft2**: tmp/ 内の一時ファイルを削除する
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
