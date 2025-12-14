# state.md

> **現在地を示す Single Source of Truth**
>
> LLM はセッション開始時に必ずこのファイルを読み、focus と playbook を確認すること。

---

## focus

```yaml
current: thanks4claudecode  # 現在作業中のプロジェクト名
project: plan/project.md
```

---

## playbook

```yaml
active: plan/active/playbook-m016-release-preparation.md
branch: feat/final-release-preparation
```

---

## goal

```yaml
milestone: M016  # リリース準備：自己認識システム完成（完了）
phase: done  # 全 phase 完了
self_complete: true
last_completed_milestone: M016 (achieved: 2025-12-14)
```

---

## session

```yaml
last_start: 2025-12-14 10:29:19
last_clear: 2025-12-13 00:30:00
```

---

## config

```yaml
security: admin
learning:
  operator: hybrid
  expertise: intermediate
```

---

## 参照

| ファイル | 役割 |
|----------|------|
| CLAUDE.md | LLM の振る舞いルール |
| plan/project.md | プロジェクト計画 |
| docs/repository-map.yaml | 全ファイルマッピング（自動生成） |
| docs/folder-management.md | フォルダ管理ルール |
