# playbook-m149a-critic-guard-fix.md

> **critic-guard.sh の self_complete フラグ信頼性向上**
>
> 致命的欠陥: self_complete がセッション跨ぎで残り、古いPASSで新しいdoneを許可してしまう

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
  critic-guard.sh の self_complete フラグにセッション/フェーズ情報を追加し、
  セッション跨ぎでの信頼性を向上させる
```

---

## goal

```yaml
summary: session-start.sh で self_complete をリセットし、セッション跨ぎ問題を解決
done_when:
  - "session-start.sh が self_complete: true を self_complete: false にリセットする"
  - "リセット時に警告メッセージが出力される"
  - "新セッション開始後に古い self_complete で done 変更がブロックされる"
  - "全テスト（flow-runtime-test）が PASS する"
```

---

## phases

### p1: 現行実装の分析と設計

**goal**: self_complete フラグの問題点を特定し、修正設計を確定

#### subtasks

- [ ] **p1.1**: state.md の verification セクション構造を確認
  - executor: claudecode
  - test_command: `grep -A5 "verification" state.md | grep -q "self_complete" && echo PASS || echo FAIL`
  - validations:
    - technical: "verification セクションの構造を把握"
    - consistency: "現在の self_complete フラグの形式を確認"
    - completeness: "修正に必要な情報が揃っている"

- [ ] **p1.2**: 修正設計を決定（self_complete に検証対象を追加）
  - executor: claudecode
  - test_command: `grep -q "self_complete" state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "self_complete を session-start.sh でリセットする設計を採用"
    - consistency: "既存の state.md 構造と整合"
    - completeness: "critic-guard.sh + session-start.sh への影響を列挙"
  - note: |
    採用設計: session-start.sh で self_complete: true → false にリセット
    理由: シンプルで確実。フェーズID追加は将来の拡張として保留

**status**: pending
**max_iterations**: 3

---

### p2: critic-guard.sh の修正

**goal**: self_complete の検証ロジックを強化

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: critic-guard.sh に self_complete.phase チェックを追加
  - executor: claudecode
  - test_command: `grep -q "self_complete.*phase\|PHASE_ID" .claude/hooks/critic-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "self_complete のフェーズIDを検証するロジックが追加されている"
    - consistency: "現在編集中のファイル（playbook）のフェーズと一致するか確認"
    - completeness: "不一致時はブロック（exit 2）"

- [ ] **p2.2**: critic-guard.sh のエラーメッセージを更新
  - executor: claudecode
  - test_command: `grep -q "古い\|stale\|expired" .claude/hooks/critic-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "「古い critic PASS は無効です」のメッセージが追加"
    - consistency: "既存のエラーメッセージ形式と整合"
    - completeness: "対処法が明記されている"

**status**: pending
**max_iterations**: 5

---

### p3: session-start.sh の修正

**goal**: セッション開始時に self_complete をリセット（または無効化警告）

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: session-start.sh に self_complete リセットロジックを追加
  - executor: claudecode
  - test_command: `grep -q "self_complete.*false\|reset.*self_complete" .claude/hooks/session-start.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "self_complete: true が残っている場合、false にリセット"
    - consistency: "state.md の他のフィールドに影響しない"
    - completeness: "リセット時に警告メッセージを出力"

**status**: pending
**max_iterations**: 3

---

### p4: critic SubAgent の修正（必要な場合）

**goal**: critic が self_complete 記録時にフェーズ情報を含める

**depends_on**: [p3]

#### subtasks

- [ ] **p4.1**: critic.md の出力形式を確認
  - executor: claudecode
  - test_command: `grep -q "self_complete" .claude/agents/critic.md && echo PASS || echo FAIL`
  - validations:
    - technical: "critic が self_complete を設定する方法を確認"
    - consistency: "state.md への書き込み形式を把握"
    - completeness: "修正が必要かどうか判断"

- [ ] **p4.2**: critic.md を修正（必要な場合）
  - executor: claudecode
  - test_command: `grep -q "phase\|playbook" .claude/agents/critic.md && echo PASS || echo FAIL`
  - validations:
    - technical: "self_complete にフェーズ情報を含める指示が追加"
    - consistency: "既存の critic 動作と整合"
    - completeness: "state.md への書き込み形式が明確"
  - note: "critic が直接 state.md を編集しない場合、この subtask はスキップ"

**status**: pending
**max_iterations**: 3

---

### p_final: 完了検証

**goal**: 修正が正しく動作することを検証

**depends_on**: [p4]

#### subtasks

- [ ] **p_final.1**: 古い self_complete で新しい done 変更がブロックされる
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
  1. critic-guard.sh を復元
     git checkout HEAD -- .claude/hooks/critic-guard.sh

  2. session-start.sh を復元
     git checkout HEAD -- .claude/hooks/session-start.sh

  3. critic.md を復元（変更した場合）
     git checkout HEAD -- .claude/agents/critic.md

  4. state.md の verification セクションを復元
     git checkout HEAD -- state.md
```

---

## notes

### 問題の詳細

```yaml
シナリオ:
  1. セッションAでcritic PASS → state.md に self_complete: true
  2. セッションBで新規タスク開始
  3. 古い self_complete: true が残っている
  4. 新しい done 変更 → 誤って許可される

根本原因:
  - self_complete が単純な boolean
  - どのフェーズ/タスクで PASS したか記録されていない
  - セッション跨ぎでリセットされない
```

### 修正方針

```yaml
方針A: self_complete を詳細化
  形式: "self_complete: { phase: 'p1', playbook: 'xxx.md', timestamp: '...' }"
  検証: 現在の playbook/phase と一致するか確認

方針B: session-start でリセット
  タイミング: セッション開始時
  動作: self_complete: true → self_complete: false
  警告: 「前セッションの critic PASS は無効です」

採用: 方針A + 方針B の組み合わせ（二重防御）
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
