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
active: plan/playbook-honest-readme.md
branch: docs/honest-readme
last_archived: M078 playbook-m078-codex-mcp.md (2025-12-18)
```

---

## goal

```yaml
milestone: ad-hoc
phase: p3
done_criteria:
  - docs/current-definitions.md が存在し、最新の正しい定義が記載されている
  - docs/deprecated-references.md が存在し、発見した古い表記が記載されている
  - 古い表記が削除/修正されている
  - README.md が正確な現状を反映している
```

---

## session

```yaml
last_start: 2025-12-18 02:15:52
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

## 参照

| ファイル | 役割 |
|----------|------|
| CLAUDE.md | LLM の振る舞いルール |
| plan/project.md | プロジェクト計画 |
| docs/repository-map.yaml | 全ファイルマッピング（自動生成） |
| docs/folder-management.md | フォルダ管理ルール |
