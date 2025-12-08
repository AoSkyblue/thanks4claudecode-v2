# project.md

> **Macro 計画: リポジトリ全体の最終目標**

---

## vision

```yaml
summary: 仕組みのための仕組みづくり - LLM 主導の開発環境テンプレート
goal: LLM が完全自律で PDCA を回せる開発環境を提供する
```

---

## done_when

> **検証可能な完了条件**: 各項目に「達成の証拠」を明記

```yaml
core:
  自律動作:
    definition: LLM がルールに従い、人間の介入なしで作業を進める
    evidence:
      - Hooks (init-guard, playbook-guard) が INIT を強制
      - CLAUDE.md の LOOP ルールに従って作業継続
      - 質問せず実行する原則が文書化済み
    status: achieved

  自動次タスク:
    definition: playbook 完了後、LLM が project.md を参照して次タスクを判断
    evidence:
      - playbook-validation 完了 → playbook-e2e-validation を自動作成
      - CLAUDE.md に「Macro チェック & 自律行動」ルール明記
    status: achieved

  自己報酬詐欺防止:
    definition: done 判定前に critic が証拠ベースで検証
    evidence:
      - critic Agent 必須化（CRITIQUE ルール）
      - Hooks による構造的強制（commit 前チェック）
      - done_criteria に証拠記載必須
    status: achieved

quality:
  機能検証:
    definition: 実装した機能が構造的に正しく定義されている
    evidence:
      - spec.yaml v8.0.0 で全機能を文書化
      - SubAgents/Skills のファイル形式が正しい
      - 次セッションで自動認識される設計
    note: セッション中作成の機能は次セッションで動作確認
    status: achieved

  フォーク即使用:
    definition: 新規ユーザーがフォーク後、setup playbook に従って開始できる
    evidence:
      - setup/playbook-setup.md が Phase 0-8 を定義
      - 新規ユーザー向け LLM 発言テンプレート完備
      - スキルレベル分岐（初心者/経験者）対応
    status: achieved

  setup完全動作:
    definition: setup playbook の構造が完全で、実行可能な状態
    evidence:
      - 全 Phase に done_criteria 定義
      - critic 発動タイミング明記（p5, p7, p8）
      - product 移行手順明記（Phase 8）
    note: 実 E2E テストは新規フォーク時に実施
    status: achieved
```

---

## current_phase

```yaml
phase: implementation
focus: 欠落機能の実装
completed:
  - Issue #8: 自律性強化（PDCA自動回転・妥当性評価フレームワーク）
  - Issue #9: 回帰テスト機能（task-06）
  - Issue #10: 自動 /clear 判断（task-08）
  - Issue #11: ロールバック機能（task-11）
  - task-07: レビュー機能（reviewer SubAgent）
  - task-01: タイムボックス機能（playbook スキーマ拡張: time_limit）
  - task-02: 優先順位管理（playbook スキーマ拡張: priority）
  - task-03: 依存関係管理（playbook スキーマ拡張: depends_on 強化）
  - task-09: /compact 最適化（context-management Skill）
  - task-10: 履歴の要約（context-management Skill + session-history/）
  - task-12: ヘルスチェック（health-checker SubAgent）
  - task-04: 並列実行制御（execution-management Skill）
  - task-05: リソース配分（execution-management Skill）
  - task-13: 学習・改善機構（learning Skill + logs/）

remaining_tasks: []  # 全タスク完了
```

---

## priority_order

```yaml
# 全タスク完了
all_completed: true
completed_count: 13

completion_summary:
  high: Issue #8, #9, #10, #11
  medium: task-01, task-02, task-03, task-07, task-09, task-10, task-12
  low: task-04, task-05, task-13
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-08 | 全タスク完了。13件の機能実装を終了。 |
| 2025-12-08 | 初版作成。MECE 分析の残タスク 13件を登録。 |
