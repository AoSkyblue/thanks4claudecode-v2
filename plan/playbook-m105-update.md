# playbook-m105-update.md

> **M105 の内容を修正するクリーンアップ playbook**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/layer-architecture
created: 2025-12-20
issue: null
derives_from: null
reviewed: true
```

---

## goal

```yaml
summary: M105 の内容を「Layer 実装」から「Golden Path Verification」に書き換える
done_when:
  - M105 の name が「Golden Path Verification - 動線単位の動作テスト」に変更されている
  - M105 の done_when が動線単位のコンポーネント動作テストに書き換えられている
  - state.md が更新されている
```

---

## phases

### p1: M105 書き換え

**goal**: project.md の M105 を新しい内容に更新する

#### subtasks

- [x] **p1.1**: project.md の M105.name が「Golden Path Verification - 動線単位の動作テスト」である
  - executor: claudecode
  - test_command: `grep -q 'Golden Path Verification' plan/project.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep でパターン検出成功"
    - consistency: "PASS - M105 の ID は変更なし"
    - completeness: "PASS - name フィールドを更新"
  - validated: 2025-12-20T20:00:00

- [x] **p1.2**: project.md の M105.done_when が動線単位の7項目に更新されている
  - executor: claudecode
  - test_command: `grep -A 10 'M105' plan/project.md | grep -c '動線' | awk '{if($1>=5) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - done_when 形式が正しい"
    - consistency: "PASS - 他の milestone に影響なし"
    - completeness: "PASS - 7項目全て含まれている"
  - validated: 2025-12-20T20:00:00

**status**: done
**max_iterations**: 3

---

### p2: state.md 更新

**goal**: state.md の next セクションを更新する

#### subtasks

- [x] **p2.1**: state.md の goal セクションが M105 の新しい内容を反映している
  - executor: claudecode
  - test_command: `grep -q '計画動線' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - YAML 形式が正しい"
    - consistency: "PASS - goal セクションの構造が維持されている"
    - completeness: "PASS - done_when が M105 の内容に更新されている"
  - validated: 2025-12-20T20:00:00

**status**: done
**depends_on**: [p1]

---

### p_final: 完了検証

**goal**: 全ての変更が正しく適用されていることを確認

#### subtasks

- [x] **p_final.1**: M105 が新しい内容に書き換えられている
  - executor: claudecode
  - test_command: `grep 'M105' plan/project.md | grep -q 'Golden Path Verification' && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep で検出可能"
    - consistency: "PASS - project.md の構造が維持されている"
    - completeness: "PASS - name と done_when が両方更新されている"
  - validated: 2025-12-20T20:00:00

**status**: done
**depends_on**: [p2]

---

## final_tasks

- [x] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: done
  - executed: 2025-12-20T20:00:00
