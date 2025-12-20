# Core Functions（動線単位で確定）

> **M108 成果物**: 動線単位でコア機能を確定したドキュメント
>
> 全コンポーネントは「動線単位」で扱う。Hook/SubAgent/Skill という分類は二次的。

---

## 設計原則

```yaml
核心的理解:
  問題: コンポーネント単位（Hook/SubAgent/Skill）で考えると混乱する
  解決: 動線単位（計画/実行/検証/完了）で考える

Layer分類の基準:
  Core: ないと破綻する（計画動線 + 検証動線）
  Quality: ないと品質低下（実行動線）
  Extension: 手動代替可能（完了動線 + 共通基盤）
```

---

## state.md 構造

> **Single Source of Truth**: 以下のセクションが必須

```yaml
必須セクション:
  - ## focus: current（作業対象）, session（task/discussion）
  - ## playbook: active, branch, last_archived
  - ## goal: milestone, phase, done_when
  - ## context: mode（normal/interrupt）, interrupt_reason, return_to
  - ## verification: self_complete, user_verified
  - ## states: flow（状態遷移）, forbidden（禁止遷移）
  - ## rules: 編集ルール
  - ## session: last_start, last_end, uncommitted_warning
  - ## config: security, toolstack, roles

報酬詐欺防止:
  verification.self_complete: LLM の自己申告（critic PASS で true）
  verification.user_verified: ユーザーの確認（明示的 OK で true）
  → 両方 true でなければ phase 完了を認めない

コンテキスト制御:
  context.mode: normal → 通常作業続行
  context.mode: interrupt → 現在の作業を中断して新要求を処理
```

---

## 黄金動線

```
┌─────────────────────────────────────────────────────────────┐
│                    黄金動線のループ                          │
│                                                             │
│   計画動線 ──→ 実行動線 ──→ 検証動線 ──→ 完了動線 ──┐      │
│       ↑                                            │      │
│       └────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

| 動線 | 概要 | Layer |
|------|------|-------|
| 計画動線 | ユーザー要求 → pm → playbook → state.md | **Core** |
| 検証動線 | /crit → critic → done_criteria検証 | **Core** |
| 実行動線 | playbook → Edit/Write → Guard発火 | Quality |
| 完了動線 | phase完了 → アーカイブ → 次タスク | Extension |

---

## Core Layer（11コンポーネント）

> **これがないとシステムが破綻する。凍結対象。**

### 計画動線 Core（6コンポーネント）

```
ユーザープロンプト
      ↓
 prompt-guard ── タスク検出、pm 必須警告
      ↓
 /task-start ── 起点コマンド
      ↓
     pm ──────── playbook 作成
      ↓
   state ─────── state.md 更新
      ↓
plan-management ─ 運用ガイド適用
      ↓
 playbook 完成 → 実行動線へ
```

| コンポーネント | Type | Role | なぜ Core か |
|---------------|------|------|-------------|
| prompt-guard.sh | hook | タスク検出、pm必須警告 | タスク要求を検出しpmを強制する入口 |
| task-start.md | command | 計画動線の起点 | project.mdからplaybookを導出する唯一の正規ルート |
| pm.md | subagent | playbook作成 | playbookを作成できる唯一の存在 |
| state | skill | state.md管理 | state.mdの更新ロジックを集約 |
| plan-management | skill | playbook運用ガイド | playbook作成時のルール適用 |
| playbook-init.md | command | playbook直接作成 | /task-startへのエイリアス、互換性維持 |

### 検証動線 Core（5コンポーネント）

```
 Phase完了宣言
      ↓
   /crit ─────── 検証起点
      ↓
  critic ─────── done_criteria 検証
      ↓
critic-guard ─── critic PASS 必須
      ↓
 PASS/FAIL 判定 → 完了動線へ
```

| コンポーネント | Type | Role | なぜ Core か |
|---------------|------|------|-------------|
| crit.md | command | 検証起点コマンド | criticを呼び出す唯一の正規ルート |
| critic.md | subagent | done_criteria検証 | done_criteriaを検証できる唯一の存在 |
| critic-guard.sh | hook | critic PASS必須 | phase完了時にcriticを強制 |
| test | skill | test_command実行 | done_criteriaのtest_commandを実行 |
| lint | skill | 整合性チェック | 構造的整合性を検証 |

---

## Quality Layer（10コンポーネント）

> **これがないと品質低下するが、動作はする。保護対象。**

### 実行動線 Quality

```
 playbook 読込
      ↓
 init-guard ──── 必須ファイル Read 強制
      ↓
┌─────────────────────────────────────┐
│ PreToolUse ガード群（並列発火）      │
│  ├─ playbook-guard（playbook 存在） │
│  ├─ check-main-branch（main 禁止）  │
│  ├─ check-protected-edit（HARD_BLOCK）│
│  ├─ consent-guard（危険操作同意）    │
│  └─ pre-bash-check（Bash 制御）     │
└─────────────────────────────────────┘
      ↓
 Edit/Write/Bash 実行
      ↓
 subtask-guard ─ 3観点検証
      ↓
 scope-guard ─── done_criteria 変更検出
      ↓
 lint-checker / test-runner
```

| コンポーネント | Type | Role | なぜ Quality か |
|---------------|------|------|---------------|
| init-guard.sh | hook | 必須ファイルRead強制 | state.md/playbookのReadを強制 |
| playbook-guard.sh | hook | playbook存在チェック | playbook=nullでEdit/Writeをブロック |
| subtask-guard.sh | hook | 3観点検証 | subtask完了時の検証を強制 |
| scope-guard.sh | hook | done_criteria変更検出 | スコープクリープを防止 |
| check-protected-edit.sh | hook | HARD_BLOCKファイル保護 | CLAUDE.md等の編集を防止 |
| pre-bash-check.sh | hook | 危険コマンドブロック | rm -rf等をブロック |
| consent-guard.sh | hook | 危険操作同意取得 | 破壊的操作前にユーザー確認 |
| check-main-branch.sh | hook | mainブランチ保護 | mainでの直接編集を防止 |
| lint-checker | skill | 静的解析 | コード品質を保証 |
| test-runner | skill | テスト実行 | テスト通過を保証 |

---

## Extension Layer（15コンポーネント）

> **手動で代替可能。あると便利。柔軟に変更可能。**

### 完了動線（7コンポーネント）

```
 全 Phase 完了
      ↓
archive-playbook ─ アーカイブ提案
      ↓
cleanup-hook ──── tmp/ クリーンアップ
      ↓
create-pr-hook ─── PR 作成
      ↓
 post-loop ────── 完了後処理
      ↓
     pm ────────── 次タスク導出
      ↓
 state / context-management / focus
      ↓
次の計画動線へ or セッション終了
```

| コンポーネント | Type | Role |
|---------------|------|------|
| archive-playbook.sh | hook | playbookアーカイブ |
| cleanup-hook.sh | hook | tmp/クリーンアップ |
| create-pr-hook.sh | hook | PR作成 |
| post-loop | skill | 完了後処理 |
| context-management | skill | コンテキスト管理 |
| rollback.md | command | Gitロールバック |
| state-rollback.md | command | state.mdロールバック |

### 共通基盤（5コンポーネント）

| コンポーネント | Type | Role |
|---------------|------|------|
| session-start.sh | hook | セッション初期化 |
| session-end.sh | hook | セッション終了処理 |
| pre-compact.sh | hook | コンパクト前処理 |
| stop-summary.sh | hook | 中断時サマリー |
| log-subagent.sh | hook | SubAgentログ |

### 横断的整合性（3コンポーネント）

| コンポーネント | Type | Role |
|---------------|------|------|
| check-coherence.sh | hook | focus/playbook/branch整合性 |
| depends-check.sh | hook | playbook間依存関係 |
| executor-guard.sh | hook | executor制御 |

---

## Layer判定基準

| 基準 | Core | Quality | Extension |
|------|------|---------|-----------|
| これがないと？ | **破綻** | 品質低下 | 不便 |
| 代替手段 | なし | あるが危険 | あり |
| 変更ポリシー | **凍結** | 保護 | 柔軟 |
| 属する動線 | 計画+検証 | 実行 | 完了+共通 |

---

## 統計

| Layer | コンポーネント数 | 動線 |
|-------|-----------------|------|
| Core | 11 | 計画動線(6) + 検証動線(5) |
| Quality | 10 | 実行動線 |
| Extension | 15 | 完了動線(7) + 共通(5) + 横断(3) |
| **合計** | **36** | - |

---

## 参照

| ファイル | 役割 |
|----------|------|
| governance/core-manifest.yaml | 動線ベースLayer定義（v3） |
| docs/layer-architecture-design.md | 設計思想の詳細 |
| .claude/hooks/session-start.sh | 動線単位認識の表示 |

---

*Created: 2025-12-20 (M108)*
