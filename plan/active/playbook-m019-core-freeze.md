# playbook-m019-core-freeze.md

> **基幹システム凍結 & 依存関係自動解析**

---

## meta

```yaml
project: thanks4claudecode
branch: feat/core-freeze
created: 2025-12-13
issue: null
derives_from: M019
reviewed: false
```

---

## goal

```yaml
summary: |
  基幹システム（Hooks, SubAgents, Skills, CLAUDE.md, state.md）の最終レビューと凍結化。
  依存関係の自動解析機能を generate-repository-map.sh に統合し、「基幹部分はもう触りません」という
  状態を構造的に強制する。
done_when:
  - 基幹システムのレビュー完了と問題点の整理
  - CORE_FREEZE.md の作成と公開
  - 基幹ファイルへのアクセス制限強化
  - 依存関係の自動解析が実装・統合される
```

---

## phases

### p0: 基幹システム最終レビュー

**目標**: Hooks（30個）、SubAgents（7個）、Skills（13個）、CLAUDE.md、state.md の設計・整合性・問題点を抽出

```yaml
subtasks:
  - id: p0.1
    criterion: "Hooks の設計仕様を分析し、整合性チェック結果を tmp/hooks-review.md に記録している"
    executor: claudecode
    test_command: "test -f tmp/hooks-review.md && grep -q '## 整合性チェック' tmp/hooks-review.md && echo PASS || echo FAIL"

  - id: p0.2
    criterion: "SubAgents の設計仕様を分析し、整合性チェック結果を tmp/agents-review.md に記録している"
    executor: claudecode
    test_command: "test -f tmp/agents-review.md && grep -q '## 整合性チェック' tmp/agents-review.md && echo PASS || echo FAIL"

  - id: p0.3
    criterion: "Skills の設計仕様を分析し、整合性チェック結果を tmp/skills-review.md に記録している"
    executor: claudecode
    test_command: "test -f tmp/skills-review.md && grep -q '## 整合性チェック' tmp/skills-review.md && echo PASS || echo FAIL"

  - id: p0.4
    criterion: "CLAUDE.md と state.md の仕様を分析し、整合性チェック結果を tmp/core-review.md に記録している"
    executor: claudecode
    test_command: "test -f tmp/core-review.md && grep -q '## 整合性チェック' tmp/core-review.md && echo PASS || echo FAIL"

  - id: p0.5
    criterion: "全レビュー結果を統合し、最終報告書 tmp/m019-review-summary.md を作成している"
    executor: claudecode
    test_command: "test -f tmp/m019-review-summary.md && grep -q '## 問題点' tmp/m019-review-summary.md && echo PASS || echo FAIL"

status: done
max_iterations: 5
```

---

### p1: 凍結宣言 & 保護ルール強化

**目標**: CORE_FREEZE.md を作成し、基幹ファイルへのアクセス制限と変更承認プロセスを定義

```yaml
subtasks:
  - id: p1.1
    criterion: "docs/CORE_FREEZE.md が作成され、凍結方針・対象・変更承認プロセスが記載されている"
    executor: claudecode
    test_command: "test -f docs/CORE_FREEZE.md && grep -q '## 変更承認プロセス' docs/CORE_FREEZE.md && echo PASS || echo FAIL"

  - id: p1.2
    criterion: "docs/protected-files-extended.md が作成され、基幹ファイル一覧と保護レベルが記載されている"
    executor: claudecode
    test_command: "test -f docs/protected-files-extended.md && grep -q 'HARD_BLOCK' docs/protected-files-extended.md && echo PASS || echo FAIL"

  - id: p1.3
    criterion: ".claude/protected-files.txt に基幹ファイルが HARD_BLOCK として登録されている"
    executor: user
    test_command: "手動確認: .claude/protected-files.txt で基幹ファイルが HARD_BLOCK として登録されていることを確認"

  - id: p1.4
    criterion: ".claude/hooks/core-freeze-guard.sh が実装され、凍結ファイルへのアクセスを監視している"
    executor: claudecode
    test_command: "test -f .claude/hooks/core-freeze-guard.sh && grep -q 'CORE_FREEZE' .claude/hooks/core-freeze-guard.sh && echo PASS || echo FAIL"

status: done
max_iterations: 5
```

---

### p2: 依存関係自動解析実装

**目標**: generate-repository-map.sh に依存関係の自動抽出・解析機能を統合

```yaml
subtasks:
  - id: p2.1
    criterion: "generate-repository-map.sh に Hook → SubAgent → Skill の依存チェーン抽出機能が実装されている"
    executor: codex
    test_command: |
      bash .claude/hooks/generate-repository-map.sh && \
      grep -q 'dependencies' docs/repository-map.yaml && \
      grep -q 'depends_on' docs/repository-map.yaml && \
      echo PASS || echo FAIL

  - id: p2.2
    criterion: "docs/repository-map.yaml の dependencies セクションに Hook → SubAgent → Skill の関連が depends_on_agents/hooks/frameworks 形式で記載されている"
    executor: claudecode
    test_command: "test -f docs/repository-map.yaml && grep -qE 'depends_on_(agents|hooks|frameworks)' docs/repository-map.yaml && echo PASS || echo FAIL"

  - id: p2.3
    criterion: "docs/dependency-chain-analysis.md が作成され、Hook → SubAgent → Skill の全チェーンが可視化されている"
    executor: claudecode
    test_command: "test -f docs/dependency-chain-analysis.md && grep -q '## Hook → SubAgent → Skill チェーン' docs/dependency-chain-analysis.md && echo PASS || echo FAIL"

  - id: p2.4
    criterion: "generate-repository-map.sh が playbook 完了時に自動的に依存関係を更新している"
    executor: claudecode
    test_command: "手動確認: generate-repository-map.sh を実行して依存関係が正しく更新されることを確認"

status: done
max_iterations: 5
```

---

### p3: クリーンアップ & 整理

**目標**: 一時ファイルを削除し、凍結宣言をアナウンス

```yaml
subtasks:
  - id: p3.1
    criterion: "tmp/ フォルダの一時ファイルがクリーンアップされている（tmp/m019-*.md が削除されている）"
    executor: claudecode
    test_command: "test ! -f tmp/m019-review-summary.md && test ! -f tmp/hooks-review.md && echo PASS || echo FAIL"

  - id: p3.2
    criterion: "最終的な整合性チェック（state.md と playbook が一致）がパスしている"
    executor: claudecode
    test_command: "bash .claude/hooks/check-coherence.sh && echo PASS || echo FAIL"

  - id: p3.3
    criterion: "M019 が project.milestone で achieved に更新されている"
    executor: claudecode
    test_command: "grep -q 'M019' plan/project.md && grep -A 1 'M019' plan/project.md | grep -q 'status: achieved' && echo PASS || echo FAIL"

status: pending
max_iterations: 5
```

---

## 備考

このタスクは「基幹部分はもう触りません」という状態を構造的に強制するための最重要マイルストーン。
以降の基幹システムへの変更は、CORE_FREEZE.md で定義された厳格な承認プロセスを経る必要がある。

---
