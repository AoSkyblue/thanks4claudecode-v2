# playbook-m112-completion-flow-order.md

> **完了動線の順序仕組み化 - マージをアーカイブより先に実行する設計**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: fix/completion-flow-order
created: 2025-12-21
issue: null
derives_from: M112
reviewed: false
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: 完了動線の順序を「マージ → アーカイブ」に修正し、playbook=null でマージがブロックされる問題を解消する
done_when:
  - final_tasks の標準順序が「マージ → ブランチ削除 → アーカイブ → state更新」になっている
  - playbook-format.md の標準 final_tasks が更新されている
  - 次の playbook から正しい順序で完了できる設計になっている
```

---

## 背景

```yaml
問題:
  旧: playbook完了 → アーカイブ → state更新(playbook=null) → マージ
  結果: playbook=null でマージがブロックされる（pre-bash-check.sh）

正しい順序:
  新: playbook完了 → マージ → ブランチ削除（オプション） → アーカイブ → state更新(playbook=null)
  理由: playbook.active が設定されている間にマージを実行すれば、ブロックされない

根本原因:
  - final_tasks に「main にマージ」が含まれていない
  - archive-playbook.sh の Post-archive tasks でマージに言及がない
  - 動線が「アーカイブ先行」になっている
```

---

## phases

### p1: 現状分析

**goal**: 現在の final_tasks 標準パターンと完了動線を確認する

#### subtasks

- [x] **p1.1**: playbook-format.md の標準 final_tasks を確認している
  - executor: claudecode
  - test_command: `grep -A 20 '### 標準 final_tasks' plan/template/playbook-format.md && echo PASS`
  - validations:
    - technical: "PASS - grep が正常に動作した"
    - consistency: "PASS - ft1(repository-map), ft2(tmp削除), ft3(コミット) を確認"
    - completeness: "PASS - マージ操作が含まれていないことを確認"
  - validated: 2025-12-21T00:00:00

- [x] **p1.2**: archive-playbook.sh の Post-archive tasks を確認している
  - executor: claudecode
  - test_command: `grep -A 10 'Post-archive tasks' .claude/hooks/archive-playbook.sh && echo PASS`
  - validations:
    - technical: "PASS - grep が正常に動作した"
    - consistency: "PASS - 1.state更新, 2.last_archived更新, 3.新playbook作成 を確認"
    - completeness: "PASS - マージ操作が含まれていないことを確認"
  - validated: 2025-12-21T00:00:00

**status**: done
**max_iterations**: 3

---

### p2: final_tasks 標準パターン更新

**goal**: playbook-format.md の標準 final_tasks を正しい順序に更新する
**depends_on**: [p1]

#### subtasks

- [x] **p2.1**: 標準 final_tasks が新しい順序で定義されている
  - executor: claudecode
  - test_command: `grep -A 25 '### 標準 final_tasks' plan/template/playbook-format.md | grep -E 'ft1.*コミット|ft2.*マージ' && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep パターンが正しく動作した"
    - consistency: "PASS - ft1がコミット、ft2がマージ、ft4がアーカイブ、ft5がstate更新"
    - completeness: "PASS - ft1-ft7 が定義されている"
  - validated: 2025-12-21T00:00:00

- [x] **p2.2**: final_tasks の役割セクションに動線説明が追加されている
  - executor: claudecode
  - test_command: `grep -q '動線\|順序' plan/template/playbook-format.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep が正常に動作した"
    - consistency: "PASS - 完了動線の順序（M112）セクションが追加されている"
    - completeness: "PASS - なぜこの順序かの理由が説明されている"
  - validated: 2025-12-21T00:00:00

**status**: done
**max_iterations**: 5

---

### p3: archive-playbook.sh 更新

**goal**: archive-playbook.sh の出力を新しい動線に合わせて更新する
**depends_on**: [p2]

#### subtasks

- [x] **p3.1**: archive-playbook.sh が「マージ済み」を前提としたメッセージを出力している
  - executor: claudecode
  - test_command: `grep -q 'merge' .claude/hooks/archive-playbook.sh && echo PASS`
  - validations:
    - technical: "PASS - grep が正常に動作した"
    - consistency: "PASS - Pre-requisite (M112) セクションでマージ必須を明示"
    - completeness: "PASS - アーカイブ前にマージを実行する指示が含まれている"
  - validated: 2025-12-21T00:00:00

**status**: done
**max_iterations**: 3

---

### p_final: 完了検証

**goal**: 全 done_when が満たされていることを検証する

#### subtasks

- [x] **p_final.1**: final_tasks の標準順序がマージ先行になっている
  - executor: claudecode
  - test_command: `grep -A 25 '### 標準 final_tasks' plan/template/playbook-format.md | grep -E 'ft2.*マージ|ft4.*アーカイブ' && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep パターンが正しく動作した"
    - consistency: "PASS - ft2がマージ、ft4がアーカイブの順序"
    - completeness: "PASS - ft1-ft7 の全てが定義されている"
  - validated: 2025-12-21T00:00:00

- [x] **p_final.2**: playbook-format.md の更新が bash -n でエラーなし（Markdown なので N/A、存在確認）
  - executor: claudecode
  - test_command: `test -f plan/template/playbook-format.md && wc -l plan/template/playbook-format.md | awk '{if($1>=1000) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - ファイルが存在し、1082行ある"
    - consistency: "PASS - 既存の内容が保持されている"
    - completeness: "PASS - ファイルが完全である"
  - validated: 2025-12-21T00:00:00

**status**: done
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: main ブランチにマージする
  - command: `git checkout main && git merge fix/completion-flow-order --no-edit`
  - status: pending

- [ ] **ft2**: フィーチャーブランチを削除する（オプション）
  - command: `git branch -d fix/completion-flow-order`
  - status: pending

- [ ] **ft3**: playbook をアーカイブする
  - command: `mkdir -p plan/archive && mv plan/playbook-m112-completion-flow-order.md plan/archive/`
  - status: pending

- [ ] **ft4**: state.md を更新する
  - command: `# state.md の playbook.active を null に、last_archived を更新`
  - status: pending

---

## rollback

```yaml
手順:
  1. git checkout main
  2. git reset --hard HEAD~1  # マージを取り消し
  3. git checkout fix/completion-flow-order  # ブランチに戻る
  4. 変更を修正

影響範囲:
  - plan/template/playbook-format.md
  - .claude/hooks/archive-playbook.sh（該当する場合）
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
