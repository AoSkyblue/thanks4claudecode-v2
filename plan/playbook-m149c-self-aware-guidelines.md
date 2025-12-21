# playbook-m149c-self-aware-guidelines.md

> **RUNBOOK.md への自覚的動作ガイドライン追加**
>
> 問題: 「LLMが判断すべき瞬間」が曖昧。ガード依存を前提とした記述

---

## meta

```yaml
schema_version: v2
project: self-aware-operation
branch: feat/m149-self-aware-operation
created: 2025-12-21
issue: null
derives_from: M149
reviewed: false
roles:
  worker: claudecode
  reviewer: codex

user_prompt_original: |
  RUNBOOK.md に「自覚的動作のガイドライン」セクションを追加し、
  LLMがガードなしでも正しく動けるための原則を明文化する
```

---

## goal

```yaml
summary: RUNBOOK.md に自覚的動作ガイドラインを追加し、LLMの自律性を高める
done_when:
  - "RUNBOOK.md に 'Self-Aware Operation' セクションが追加されている"
  - "「判断すべき瞬間」が具体的に列挙されている"
  - "ガードなしでも正しく動くための原則が明記されている"
  - "session-start.sh の出力と整合している"
```

---

## phases

### p1: ガイドライン設計

**goal**: 自覚的動作の原則を設計

#### subtasks

- [ ] **p1.1**: 追加内容を notes セクションで確認
  - executor: claudecode
  - test_command: `grep -q "判断すべき4つの瞬間" plan/playbook-m149c-self-aware-guidelines.md && echo PASS || echo FAIL`
  - validations:
    - technical: "notes に追加内容案が既に記載されている"
    - consistency: "CLAUDE.md Core Contract と整合"
    - completeness: "4つの瞬間 + 5原則が定義されている"
  - note: "設計は notes に既に記載済み。確認のみ"

**status**: pending
**max_iterations**: 3

---

### p2: RUNBOOK.md の更新

**goal**: Self-Aware Operation セクションを追加

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: RUNBOOK.md に Self-Aware Operation セクションを追加
  - executor: claudecode
  - test_command: `grep -q "Self-Aware Operation\|自覚的動作" RUNBOOK.md && echo PASS || echo FAIL`
  - validations:
    - technical: "新しいセクションが追加されている"
    - consistency: "既存のセクション構造と整合"
    - completeness: "4つの判断瞬間が全て記載されている"

- [ ] **p2.2**: 「5つの自律行動原則」を追加
  - executor: claudecode
  - test_command: `grep -c "原則\|Principle" RUNBOOK.md | [ $(cat) -ge 5 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "5つの原則が明記されている"
    - consistency: "CLAUDE.md の Non-Negotiables と整合"
    - completeness: "各原則に具体的なアクションが紐付いている"

**status**: pending
**max_iterations**: 5

---

### p3: session-start.sh との整合確認

**goal**: RUNBOOK.md とsession-start.sh の出力が整合していることを確認

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: session-start.sh の CORE セクションを確認
  - executor: claudecode
  - test_command: `grep -q "CORE" .claude/hooks/session-start.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "CORE セクションの内容を確認"
    - consistency: "RUNBOOK.md の原則と一致している"
    - completeness: "不整合がない"

- [ ] **p3.2**: 必要に応じて session-start.sh を更新
  - executor: claudecode
  - test_command: `grep -q "Self-Aware\|自覚" .claude/hooks/session-start.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "RUNBOOK.md への参照が追加されている（必要な場合）"
    - consistency: "既存の出力形式と整合"
    - completeness: "自覚的動作への誘導が含まれている"
  - note: "session-start.sh の変更が大きくなる場合はスキップ"

**status**: pending
**max_iterations**: 3

---

### p_final: 完了検証

**goal**: ガイドラインが正しく追加されていることを検証

**depends_on**: [p3]

#### subtasks

- [ ] **p_final.1**: RUNBOOK.md に必要なセクションが存在する
  - executor: claudecode
  - test_command: `grep -q "Self-Aware" RUNBOOK.md && grep -q "判断\|Judgment" RUNBOOK.md && echo PASS || echo FAIL`
  - validations:
    - technical: "Self-Aware Operation セクションが存在する"
    - consistency: "判断すべき瞬間が列挙されている"
    - completeness: "原則が明記されている"

- [ ] **p_final.2**: テストが全て PASS する
  - executor: claudecode
  - test_command: `bash scripts/flow-runtime-test.sh 2>&1 | grep -q "ALL.*PASS" && echo PASS || echo FAIL`
  - validations:
    - technical: "テストが正常に実行される"
    - consistency: "新機能が既存テストを破壊していない"
    - completeness: "主要テストが全て PASS"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## rollback

```yaml
手順:
  1. RUNBOOK.md を復元
     git checkout HEAD -- RUNBOOK.md

  2. session-start.sh を復元（変更した場合）
     git checkout HEAD -- .claude/hooks/session-start.sh
```

---

## notes

### 追加するセクション案

```markdown
## Self-Aware Operation（自覚的動作）

LLMはガードに頼らず、自律的に正しい動線を選ぶべきです。
ガードは「最後の砦」であり、最初から正しく動くことが期待されます。

### 判断すべき4つの瞬間

| 瞬間 | 正しい行動 |
|------|-----------|
| セッション開始 | state.md → project.md → playbook を読む |
| タスク検出 | playbook=null なら pm を呼ぶ（返答前に） |
| phase完了 | critic を呼ぶ（done変更前に） |
| done変更 | self_complete: true を確認（変更前に） |

### 5つの自律行動原則

1. **Read Before Act**: 編集前に必ず対象ファイルを読む
2. **Plan Before Execute**: playbook なしで実装しない
3. **Verify Before Complete**: critic なしで done にしない
4. **State Before Branch**: state.md と branch の整合を確認
5. **Guard as Fallback**: ガードに頼らず自分で判断する

### ガードは最後の砦

```yaml
期待される動作:
  LLM が自律的に正しい動線を選ぶ
  → ガードは発火しない

実際の動作（許容される）:
  LLM が間違った動線を選ぶ
  → ガードがブロックする
  → LLM が正しい動線に戻る

問題のある動作:
  LLM がガードに頼って動く
  → 「ガードがブロックするまで進む」
  → 非効率、自覚的ではない
```
```

### CLAUDE.md との関係

```yaml
CLAUDE.md:
  - Core Contract（pm必須、playbook必須）を定義
  - Non-Negotiables（no_self_approval等）を定義
  - しかし「いつ判断すべきか」は曖昧

RUNBOOK.md:
  - 「いつ判断すべきか」を明確化
  - 具体的なアクションを示す
  - ガードなしでも動ける原則を追加
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
