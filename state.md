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
active: plan/active/playbook-state-injection.md
branch: feat/state-injection
```

---

## goal

```yaml
milestone: M005  # 確実な初期化システム（StateInjection）
phase: p4        # ドキュメント更新とクリーンアップ
done_criteria:
  - "ls docs/state-injection-guide.md でファイルが存在する"
  - "grep '注入フロー' docs/state-injection-guide.md が成功する"
  - "ls .claude/draft-injection-design.md が失敗する（削除済み）"
  - "ls .claude/hooks/test-injection.sh が失敗する（削除済み）"
  - "grep 'phase: p4' state.md が成功する"
```

---

## session

```yaml
last_start: 2025-12-13 00:52:06
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
| docs/feature-map.md | 機能マップ |
