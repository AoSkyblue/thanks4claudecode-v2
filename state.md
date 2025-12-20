# state.md

> **現在地を示す Single Source of Truth**
>
> LLM はセッション開始時に必ずこのファイルを読み、focus と playbook を確認すること。

---

## focus

```yaml
current: plan-template  # 現在作業中のプロジェクト名
project: plan/project.md
```

---

## playbook

```yaml
active: plan/playbook-m105-update.md
branch: feat/layer-architecture
last_archived: plan/playbook-m104-layer-architecture.md
```

---

## goal

```yaml
milestone: M105 (in_progress)
phase: p1
done_when:
  - "[ ] 計画動線の全コンポーネント（6個）が正しく動作する"
  - "[ ] 実行動線の全コンポーネント（11個）が正しく動作する"
  - "[ ] 検証動線の全コンポーネント（6個）が正しく動作する"
  - "[ ] 完了動線の全コンポーネント（8個）が正しく動作する"
  - "[ ] 共通基盤の全コンポーネント（6個）が正しく動作する"
  - "[ ] 横断的整合性の全コンポーネント（3個）が正しく動作する"
  - "[ ] 動作不良（subtask-guard WARN モード、critic-guard playbook 未対応）が修正されている"
next: null
```

---

## session

```yaml
last_start: 2025-12-20 19:30:00
last_clear: 2025-12-13 00:30:00
```

---

## config

```yaml
security: admin
toolstack: A  # A: Claude Code only | B: +Codex | C: +Codex+CodeRabbit
roles:
  orchestrator: claudecode  # 監督・調整・設計（常に claudecode）
  worker: claudecode        # 実装担当（A: claudecode, B/C: codex）
  reviewer: claudecode      # レビュー担当（A/B: claudecode, C: coderabbit）
  human: user               # 人間の介入（常に user）
```

---

## COMPONENT_REGISTRY

```yaml
hooks: 22
agents: 3
skills: 7
commands: 8
last_verified: 2025-12-20
```

> **Single Source of Truth**: コンポーネント数の正規値。
> 正本は governance/core-manifest.yaml。

---

## SPEC_SNAPSHOT

```yaml
readme:
  hooks: 22
  milestone_count: 50
project:
  total: 50
  achieved: 50
  pending: 0
last_checked: 2025-12-20
```

> **仕様同期スナップショット**: README/project.md の数値を記録。
> check-spec-sync.sh が実行時にこの値と実態を比較し、乖離があれば警告を出力する。

---

## FREEZE_QUEUE

```yaml
queue: []
freeze_period_days: 7
```

> **削除予定ファイルの凍結キュー**: 削除前に一定期間保持するファイルのリスト。
> freeze-file.sh でファイルを追加、delete-frozen.sh で凍結期間経過後に削除。
> 形式: `- { path: "path/to/file", freeze_date: "YYYY-MM-DD", reason: "理由" }`

---

## DELETE_LOG

```yaml
log: []
```

> **削除履歴ログ**: 削除されたファイルの記録。
> delete-frozen.sh が削除実行時に自動で記録。
> 形式: `- { path: "path/to/file", deleted_date: "YYYY-MM-DD", reason: "理由" }`

---

## 参照

| ファイル | 役割 |
|----------|------|
| CLAUDE.md | LLM の振る舞いルール |
| plan/project.md | プロジェクト計画 |
| docs/repository-map.yaml | 全ファイルマッピング（自動生成） |
| docs/folder-management.md | フォルダ管理ルール |
