# state.md

> **統合状態管理ファイル（Single Source of Truth）**
>
> 4つのレイヤーを管理: plan-template → workspace → setup → product
> LLMはセッション開始時に必ずこのファイルを読み、`focus.current` を確認すること。

---

## focus

```yaml
current: workspace           # plan-template | workspace | setup | product
session: task                # task | discussion (playbook作成中は一時的にdiscussion)
```

---

## security

```yaml
mode: trusted                # strict | trusted | developer | admin
```

---

## active_playbooks

```yaml
plan-template:    null
workspace:        plan/active/playbook-3layer-plan.md
setup:            setup/playbook-setup.md   # デフォルト playbook
product:          null                       # setup 完了後、product 開発用に作成
```

---

## context

```yaml
mode: normal                 # normal | interrupt
interrupt_reason: null
return_to: null
```

---

## plan_hierarchy

> **3層計画構造**: Macro → Medium → Micro

```yaml
# Macro: リポジトリ全体の最終目標
macro:
  file: plan/project.md      # 存在する場合
  exists: false              # project_context.generated と連動
  summary: null              # 未定義

# Medium: 単機能実装の中期計画（1ブランチ = 1playbook）
medium:
  file: plan/active/playbook-3layer-plan.md
  exists: true
  goal: 3層計画管理システムの実装

# Micro: セッション単位の作業（playbook の 1 Phase）
micro:
  phase: complete
  name: 全 Phase 完了
  status: done

# 上位計画参照（必要時のみ参照、通常は隔離）
upper_plans:
  vision: plan/vision.md           # WHY-ultimate
  meta_roadmap: plan/meta-roadmap.md  # HOW-to-improve
  roadmap: plan/roadmap.md         # WHAT（参照用）
```

---

## project_context

> **setup 完了後に更新される。**

```yaml
generated: false             # true = setup 完了、plan/project.md 生成済み
project_plan: null           # 生成後: plan/project.md
```

---

## layer: plan-template

```yaml
state: done
sub: v3-complete
playbook: null
```

---

## layer: workspace

```yaml
state: state_update
sub: v8-3layer-plan-guard-complete
playbook: plan/active/playbook-3layer-plan.md
```

---

## layer: setup

```yaml
state: pending
sub: null
playbook: setup/playbook-setup.md
```

### 概要
> setup/playbook-setup.md に従って環境をセットアップする。
> Phase 0-8 を完了後、plan/project.md を生成し product レイヤーへ移行。
> CATALOG.md は必要な時だけ参照。

---

## layer: product

```yaml
state: pending               # setup 完了後に有効化
sub: null
playbook: null
```

### 概要
> ユーザーが実際にプロダクトを開発するためのレイヤー。
> setup 完了後、plan/project.md を参照して TDD で開発。

---

## goal

```yaml
phase: workspace
milestone: v8-3layer-plan-guard
task: 3層計画管理システムの実装
assignee: claude_code

done_criteria:
  - plan-guard SubAgent が存在し、CLAUDE.md DISPATCH に登録されている
  - シナリオ S0-S5 が全て正しく動作する
  - 3層計画構造（Macro/Medium/Micro）が state.md に反映されている
```

### 次のステップ
```
p1: playbook 作成 (done)
p2: plan-guard SubAgent 作成
p3: CLAUDE.md DISPATCH 更新
p4: state.md 3層構造への更新
p5: シナリオテスト
```

---

## verification

```yaml
self_complete: true
user_verified: false
critic_result: CONDITIONAL_PASS
note: 動作検証は次回セッション開始時に実施
```

---

## states

```yaml
flow: pending → designing → implementing → [reviewing →] state_update → done
forbidden: [pending→implementing], [pending→done], [*→done without state_update]
```

---

## rules

```yaml
原則: focus.current のレイヤーのみ編集可能
例外: state.md の focus/context/verification は常に編集可能
保護: CLAUDE.md, CONTEXT.md は BLOCK（ユーザー許可必要）
```

---

## session_tracking

> **Hooks による自動更新。LLM の行動に依存しない。**

```yaml
last_start: 2025-12-08 00:10:45
last_end: null
uncommitted_warning: false
```

---

## 参照ファイル

| ファイル | 内容 |
|----------|------|
| CONTEXT.md | 唯一の真実源。設計思想、レイヤー構造、全コンテキスト |

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-08 | V8: 3層計画管理システム実装完了。plan-guard.md, DISPATCH 更新, plan_hierarchy 3層化 |
| - | フォーク直後の初期状態 |
