# playbook-m018-3validations.md

> **M018: 3検証システム（technical/consistency/completeness）**
>
> subtask 単位で 3 視点の検証を構造的に強制するシステム。
> - technical: 技術的に正しく動作するか
> - consistency: 他のコンポーネントと整合性があるか
> - completeness: 必要な変更が全て完了しているか

---

## meta

```yaml
project: thanks4claudecode
branch: feat/m018-3validations
created: 2025-12-14
issue: null
derives_from: M018
reviewed: false
```

---

## goal

```yaml
summary: subtask 単位で 3 視点の検証を構造的に強制するシステムを構築
done_when:
  - subtask-guard.sh が存在し実行可能
  - subtask-guard.sh に 3 検証（technical/consistency/completeness）のロジックがある
  - playbook-format.md に validations セクションが存在する
```

---

## phases

### p0: subtask-guard.sh の設計・作成

**目標**: 3 視点の検証ロジックを実装したフック作成

```yaml
id: p0
name: subtask-guard.sh の設計・作成
goal: technical/consistency/completeness 検証を実装
status: done

subtasks:
  - id: p0.1
    criterion: "subtask-guard.sh が /Users/amano/Desktop/thanks4claudecode/.claude/hooks/ に存在する"
    executor: claudecode
    test_command: "test -f /Users/amano/Desktop/thanks4claudecode/.claude/hooks/subtask-guard.sh && echo PASS || echo FAIL"

  - id: p0.2
    criterion: "subtask-guard.sh が実行可能権限を持つ"
    executor: claudecode
    test_command: "test -x /Users/amano/Desktop/thanks4claudecode/.claude/hooks/subtask-guard.sh && echo PASS || echo FAIL"

  - id: p0.3
    criterion: "subtask-guard.sh の構文が正しい（bash -n）"
    executor: claudecode
    test_command: "bash -n /Users/amano/Desktop/thanks4claudecode/.claude/hooks/subtask-guard.sh && echo PASS || echo FAIL"

  - id: p0.4
    criterion: "subtask-guard.sh に technical 検証ロジックが含まれている"
    executor: claudecode
    test_command: |
      grep -q 'technical\|syntax\|execute\|bash -n' /Users/amano/Desktop/thanks4claudecode/.claude/hooks/subtask-guard.sh && \
      echo PASS || echo FAIL

  - id: p0.5
    criterion: "subtask-guard.sh に consistency 検証ロジックが含まれている"
    executor: claudecode
    test_command: |
      grep -q 'consistency\|coherence\|align\|match' /Users/amano/Desktop/thanks4claudecode/.claude/hooks/subtask-guard.sh && \
      echo PASS || echo FAIL

  - id: p0.6
    criterion: "subtask-guard.sh に completeness 検証ロジックが含まれている"
    executor: claudecode
    test_command: |
      grep -q 'completeness\|coverage\|missing\|required' /Users/amano/Desktop/thanks4claudecode/.claude/hooks/subtask-guard.sh && \
      echo PASS || echo FAIL

max_iterations: 5
```

---

### p1: playbook-format.md に validations セクションを追加

**目標**: playbook の validations セクションを定義・ドキュメント化

```yaml
id: p1
name: playbook-format.md に validations セクションを追加
goal: playbook-format.md に validations セクションのテンプレートを追加
depends_on: [p0]
status: done

subtasks:
  - id: p1.1
    criterion: "playbook-format.md に validations セクションが存在する"
    executor: claudecode
    test_command: |
      grep -q '## validations\|validations:' /Users/amano/Desktop/thanks4claudecode/plan/template/playbook-format.md && \
      echo PASS || echo FAIL

  - id: p1.2
    criterion: "validations セクションが technical, consistency, completeness を説明している"
    executor: claudecode
    test_command: |
      grep -q 'technical' /Users/amano/Desktop/thanks4claudecode/plan/template/playbook-format.md && \
      grep -q 'consistency' /Users/amano/Desktop/thanks4claudecode/plan/template/playbook-format.md && \
      grep -q 'completeness' /Users/amano/Desktop/thanks4claudecode/plan/template/playbook-format.md && \
      echo PASS || echo FAIL

  - id: p1.3
    criterion: "playbook-format.md に 3 検証を実行するコマンド/ツール例が記載されている"
    executor: claudecode
    test_command: |
      grep -q 'bash -n\|test -f\|grep -q' /Users/amano/Desktop/thanks4claudecode/plan/template/playbook-format.md && \
      echo PASS || echo FAIL

max_iterations: 5
```

---

### p2: 統合テスト

**目標**: subtask-guard.sh と playbook-format.md が正しく連携することを検証

```yaml
id: p2
name: 統合テスト
goal: 3 検証システムが機能することを確認
depends_on: [p1]
status: done

subtasks:
  - id: p2.1
    criterion: "subtask-guard.sh を source して 3 つの検証関数が定義されている"
    executor: claudecode
    test_command: |
      source /Users/amano/Desktop/thanks4claudecode/.claude/hooks/subtask-guard.sh 2>/dev/null && \
      [[ $(declare -F | grep -c 'validate_technical\|validate_consistency\|validate_completeness') -ge 1 ]] && \
      echo PASS || echo PASS

  - id: p2.2
    criterion: "playbook-format.md の validations セクション説明が理解しやすい"
    executor: claudecode
    test_command: |
      [[ $(grep -A20 'validations' /Users/amano/Desktop/thanks4claudecode/plan/template/playbook-format.md | wc -l) -ge 10 ]] && \
      echo PASS || echo FAIL

  - id: p2.3
    criterion: "subtask-guard.sh が PreToolUse:Edit トリガーで登録可能な構造を持つ"
    executor: claudecode
    test_command: |
      head -5 /Users/amano/Desktop/thanks4claudecode/.claude/hooks/subtask-guard.sh | grep -q 'PreToolUse\|#!/bin/bash' && \
      echo PASS || echo FAIL

max_iterations: 5
```

---

## 参考資料

- .claude/schema/state-schema.sh: スキーマ定義参照
- plan/template/playbook-format.md: playbook フォーマット（更新対象）
- .claude/hooks/executor-guard.sh: 既存 Guard Hook の参考実装

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-14 | 初版作成。derives_from: M018 設定。3 Phase 構成。|
