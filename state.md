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
phase: p1        # systemMessage 注入ロジック実装
done_criteria:
  - "prompt-guard.sh に state.md 読み込みロジックが追加されている"
  - "project.md と playbook を読み込んで focus/goal/phase を抽出できる"
  - "systemMessage に以下が含まれている: focus.current, goal.milestone, goal.phase, remaining"
  - "JSON の escaping が正しく行われている（バックスラッシュ、改行）"
  - "複数回のプロンプト送信で毎回 systemMessage が注入される"
  - "実際に動作確認済み（test_method 実行）"
```

---

## session

```yaml
last_start: 2025-12-12 23:57:49
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
