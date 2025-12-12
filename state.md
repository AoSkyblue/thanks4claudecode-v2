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
phase: p3        # LLM Read 省略時の情報到達確認
done_criteria:
  - "systemMessage に含まれる情報がフォーマットされている（readable）"
  - "複数プロンプト送信時に毎回同じ形式で systemMessage が出力される"
  - "systemMessage の構造が CLAUDE.md の INIT と一致している"
  - "test-no-read.sh で LLM が Read せずに応答できることをシミュレート"
  - "実際に動作確認済み（test_method 実行）"
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
