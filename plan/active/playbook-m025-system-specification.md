# playbook-m025-system-specification.md

> **repository-map.yaml を拡張し、Claude の仕様を Single Source of Truth として統合**

---

## meta

```yaml
project: thanks4claudecode
branch: feat/m025-system-specification
created: 2025-12-15
issue: null
derives_from: M025
reviewed: false
```

---

## goal

```yaml
summary: repository-map.yaml を拡張し、Claude の行動ルール・Hook 連鎖を統合する
done_when:
  - generate-repository-map.sh に system_specification セクション生成機能が追加されている
  - repository-map.yaml に Claude 行動ルール・Hook トリガー連鎖が含まれている
  - 自動更新が 100% 安定（冪等性保証、原子的更新）
  - INIT フロー全体で冗長がなく、効率的に自己認識できることが確認される
```

---

## phases

```yaml
- id: p0
  name: 現状分析と設計
  goal: generate-repository-map.sh の現状を分析し、拡張設計を行う

  subtasks:
    - id: p0.1
      criterion: "generate-repository-map.sh の現在の構造が分析されている"
      executor: claudecode
      test_command: "test -f tmp/m025-analysis.md && echo PASS || echo FAIL"

    - id: p0.2
      criterion: "追加する system_specification セクションの設計が定義されている"
      executor: claudecode
      test_command: "grep -q 'system_specification:' tmp/m025-analysis.md && echo PASS || echo FAIL"

    - id: p0.3
      criterion: "Hook トリガー連鎖の抽出ロジックが設計されている"
      executor: claudecode
      test_command: "grep -q 'hook_chain' tmp/m025-analysis.md && echo PASS || echo FAIL"

  validations:
    technical: tmp/m025-analysis.md が存在し、設計内容が記載されている
    consistency: 設計が project.md の done_when と整合している
    completeness: 全設計要素（セクション構造、抽出ロジック、安定性対策）が含まれている

  status: done
  max_iterations: 5

- id: p1
  name: generate-repository-map.sh 拡張実装
  goal: system_specification セクション生成機能を追加する
  depends_on: [p0]

  subtasks:
    - id: p1.1
      criterion: "generate-repository-map.sh に system_specification 生成関数が追加されている"
      executor: claudecode
      test_command: "grep -q 'generate_system_specification' .claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL"

    - id: p1.2
      criterion: "Hook トリガー連鎖を抽出する関数が実装されている"
      executor: claudecode
      test_command: "grep -q 'extract_hook_chain' .claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL"

    - id: p1.3
      criterion: "Claude 行動ルール（INIT/LOOP/POST_LOOP）を抽出する関数が実装されている"
      executor: claudecode
      test_command: "grep -q 'extract_behavior_rules' .claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL"

    - id: p1.4
      criterion: "スクリプトの構文が正しい（bash -n でエラーなし）"
      executor: claudecode
      test_command: "bash -n .claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL"

  validations:
    technical: bash -n でシンタックスエラーがない
    consistency: 既存の generate_* 関数と命名規則が一致している
    completeness: 3つの新機能（system_spec, hook_chain, behavior_rules）が全て実装されている

  status: done
  max_iterations: 5

- id: p2
  name: 安定性保証の実装
  goal: 100% 安定した自動更新を実現する
  depends_on: [p1]

  subtasks:
    - id: p2.1
      criterion: "set -euo pipefail が設定されている（厳格モード）"
      executor: claudecode
      test_command: "grep -q 'set -euo pipefail' .claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL"

    - id: p2.2
      criterion: "一時ファイル経由の原子的更新が実装されている"
      executor: claudecode
      test_command: "grep -q 'TEMP_FILE.*OUTPUT_FILE\\|mv.*TEMP_FILE' .claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL"

    - id: p2.3
      criterion: "冪等性が保証されている（タイムスタンプ除外で同一結果）"
      executor: claudecode
      test_command: |
        grep -v 'generated:\|date:\|total' docs/repository-map.yaml | md5 > tmp/hash1.txt
        bash .claude/hooks/generate-repository-map.sh > /dev/null 2>&1
        grep -v 'generated:\|date:\|total' docs/repository-map.yaml | md5 > tmp/hash2.txt
        diff -q tmp/hash1.txt tmp/hash2.txt && echo PASS || echo FAIL

    - id: p2.4
      criterion: "エラー時に既存ファイルが破損しない"
      executor: claudecode
      test_command: "grep -qE 'trap|cleanup|rollback' .claude/hooks/generate-repository-map.sh && echo PASS || echo FAIL"

  validations:
    technical: 厳格モード、原子的更新、trap が全て実装されている
    consistency: 既存の cleanup-hook.sh 等の安定性パターンと一致している
    completeness: 4つの安定性要件が全て満たされている

  status: done
  max_iterations: 5

- id: p3
  name: repository-map.yaml 生成と検証
  goal: 拡張された repository-map.yaml を生成し、内容を検証する
  depends_on: [p2]

  subtasks:
    - id: p3.1
      criterion: "repository-map.yaml に system_specification セクションが存在する"
      executor: claudecode
      test_command: "grep -q '^system_specification:' docs/repository-map.yaml && echo PASS || echo FAIL"

    - id: p3.2
      criterion: "Hook トリガー連鎖が正しく記載されている"
      executor: claudecode
      test_command: "grep -q 'hook_chains:' docs/repository-map.yaml && echo PASS || echo FAIL"

    - id: p3.3
      criterion: "Claude 行動ルールが正しく記載されている"
      executor: claudecode
      test_command: "grep -q 'behavior_rules:' docs/repository-map.yaml && echo PASS || echo FAIL"

    - id: p3.4
      criterion: "YAML 構文が正しい（基本構造チェック）"
      executor: claudecode
      test_command: "grep -q '^system_specification:' docs/repository-map.yaml && grep -q '^hooks:' docs/repository-map.yaml && grep -q '^summary:' docs/repository-map.yaml && echo PASS || echo FAIL"

  validations:
    technical: YAML 基本構造が正しい
    consistency: 既存の hooks/agents/skills セクションと構造が一致している
    completeness: system_specification, hook_chains, behavior_rules の3セクションが全て含まれている

  status: done
  max_iterations: 5

- id: p4
  name: INIT フロー最適化と最終検証
  goal: INIT フローの冗長を排除し、効率的な自己認識を確認する
  depends_on: [p3]

  subtasks:
    - id: p4.1
      criterion: "INIT で読む必須ファイル数が最適化されている（5ファイル以下）"
      executor: claudecode
      test_command: |
        count=$(grep -c 'Read:' CLAUDE.md | head -1)
        [ "$count" -le 5 ] && echo PASS || echo FAIL

    - id: p4.2
      criterion: "repository-map.yaml から Claude が自身の仕様を把握できる"
      executor: claudecode
      test_command: |
        grep -q 'system_specification:' docs/repository-map.yaml && \
        grep -q 'hook_chains:' docs/repository-map.yaml && \
        grep -q 'behavior_rules:' docs/repository-map.yaml && \
        echo PASS || echo FAIL

    - id: p4.3
      criterion: "playbook 完了時に自動更新が実行される（cleanup-hook.sh 経由）"
      executor: claudecode
      test_command: "grep -q 'generate-repository-map.sh' .claude/hooks/cleanup-hook.sh && echo PASS || echo FAIL"

  validations:
    technical: 全 test_command が PASS を返す
    consistency: CLAUDE.md の INIT セクションと repository-map.yaml が整合している
    completeness: INIT フロー最適化、自己認識、自動更新の3要件が全て満たされている

  status: done
  max_iterations: 5

- id: p5
  name: クリーンアップと完了
  goal: 一時ファイルを削除し、playbook を完了する
  depends_on: [p4]

  subtasks:
    - id: p5.1
      criterion: "tmp/m025-*.md が削除されている"
      executor: claudecode
      test_command: "! ls tmp/m025-*.md 2>/dev/null && echo PASS || echo FAIL"

    - id: p5.2
      criterion: "全変更がコミットされている"
      executor: claudecode
      test_command: "git status --porcelain | wc -l | xargs test 0 -eq && echo PASS || echo FAIL"

    - id: p5.3
      criterion: "project.md の M025.done_when が全て [x] になっている"
      executor: claudecode
      test_command: "! grep -q '\\[ \\]' plan/project.md | grep -A10 'id: M025' && echo PASS || echo FAIL"

  validations:
    technical: git status がクリーン
    consistency: project.md と playbook の状態が一致している
    completeness: 一時ファイル削除、コミット、done_when 更新が全て完了している

  status: done
  max_iterations: 3
```

---

## final_tasks

```yaml
- id: ft1
  task: "repository-map.yaml を最終更新する"
  command: "bash .claude/hooks/generate-repository-map.sh"
  status: pending

- id: ft2
  task: "tmp/ 内の一時ファイルを削除する"
  command: "find tmp/ -type f -name 'm025-*' -delete"
  status: pending

- id: ft3
  task: "変更を全てコミットする"
  command: "git add -A && git status"
  status: pending
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-15 | 初版作成。統合案に基づき repository-map.yaml 拡張を設計。 |
