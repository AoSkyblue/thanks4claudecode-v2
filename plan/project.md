# project.md

> **プロジェクトの根幹計画。Claude が3層構造（project → playbook → phase）を自動運用する。**

---

## meta

```yaml
project: thanks4claudecode
created: 2025-12-10
status: active
```

---

## vision

```yaml
goal: "Claude Code の自律性と品質を継続的に向上させる"

principles:
  - 報酬詐欺防止（critic 必須）
  - 計画駆動開発（playbook 必須）
  - 構造的強制（Hooks）
  - 3層自動運用（project → playbook → phase）

success_criteria:
  - ユーザープロンプトなしで 1 playbook を完遂できる
  - compact 後も mission を見失わない
  - 次タスクを自動導出して開始できる
  - 全 Hook/SubAgent/Skill が動作確認済み
  - playbook 完了時に /clear タイミングを案内する
  - project.milestone が自動更新される
```

---

## milestones

```yaml
- id: M001
  name: "三位一体アーキテクチャ確立"
  status: achieved
  achieved_at: 2025-12-09
  playbooks:
    - playbook-reward-fraud-prevention.md

- id: M002
  name: "Self-Healing System 基盤実装"
  status: achieved
  achieved_at: 2025-12-10
  playbooks:
    - playbook-full-autonomy.md

- id: M003
  name: "PR 作成・マージの自動化"
  status: achieved
  achieved_at: 2025-12-10
  playbooks:
    - playbook-pr-automation.md

- id: M004
  name: "3層構造の自動運用システム"
  description: |
    project → playbook → phase の3層構造を確立し、
    Claude が主導で自動運用できるようにする。
    人間は意思決定とプロンプト提供のみ。
  status: achieved
  achieved_at: 2025-12-13 00:06:00
  depends_on: [M001, M002, M003]
  playbooks:
    - playbook-three-layer-system.md
  done_when:
    - [x] 用語が統一されている（Macro→project, layer廃止）
    - [x] playbook 完了時に project.milestone が自動更新される
    - [x] playbook 完了時に /clear 推奨がアナウンスされる
    - [x] 次 milestone から playbook が自動作成される
```

---

## tech_stack

```yaml
framework: Claude Code Hooks System
language: Bash/Shell
deploy: local (git-based)
database: none (file-based: state.md, playbook, project.md)
```

---

## constraints

- Hook は exit code で制御（0=通過、2=ブロック）
- state.md が Single Source of Truth
- playbook なしで Edit/Write は禁止
- critic なしで phase 完了は禁止
- main ブランチでの直接作業は禁止
- 1 playbook = 1 branch

---

## 3層構造

```
project (永続)
├── vision: 最上位目標
├── milestones[]: 中間目標
│   ├── M001: achieved
│   ├── M002: achieved
│   ├── M003: achieved
│   └── M004: in_progress ← 現在地
└── constraints: 制約条件

playbook (一時的)
├── meta.derives_from: M004  # milestone との紐付け
├── goal.done_when: milestone 達成条件
└── phases[]: 作業単位
    ├── p0: pending
    ├── p1: pending
    └── p2: pending

phase (作業単位)
├── done_criteria[]: 完了条件
├── test_method: 検証手順
└── status: pending | in_progress | done
```

---

## 自動運用フロー

```yaml
phase_complete:
  trigger: critic PASS
  action:
    - phase.status = done
    - 次の phase へ（または playbook 完了へ）

playbook_complete:
  trigger: 全 phase が done
  action:
    - playbook をアーカイブ
    - project.milestone を自動更新
      - status = achieved
      - achieved_at = now()
      - playbooks[] に追記
    - /clear 推奨をアナウンス
    - 次の milestone を特定（depends_on 分析）
    - pm で新 playbook を自動作成

project_complete:
  trigger: 全 milestone が achieved
  action:
    - project.status = completed
    - 「次の方向性を教えてください」と人間に確認
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-13 | 3層構造の自動運用システム設計。用語統一。milestone に ID 追加。 |
| 2025-12-10 | 初版作成。 |
