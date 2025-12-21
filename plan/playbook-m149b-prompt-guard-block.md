# playbook-m149b-prompt-guard-block.md

> **prompt-guard.sh の pm 必須を構造的に強制**
>
> 致命的欠陥: exit 0 で「推奨」止まり。警告を無視してタスクを進められる

---

## meta

```yaml
schema_version: v2
project: self-aware-operation
branch: feat/m149-self-aware-operation
created: 2025-12-21
issue: null
derives_from: M149
reviewed: false
roles:
  worker: claudecode
  reviewer: codex

user_prompt_original: |
  prompt-guard.sh を修正し、playbook=null でタスク検出時に
  exit 2 でブロックする（「推奨」から「必須」へ）
```

---

## goal

```yaml
summary: prompt-guard.sh を修正し、pm 必須を構造的に強制する
done_when:
  - "playbook=null + タスク検出時に exit 2 でブロックされる"
  - "ブロックメッセージに pm 呼び出し方法が明記されている"
  - "タスク検出パターンが強化されている（日本語・英語両対応）"
  - "discussion/質問系のプロンプトは許可される"
```

---

## phases

### p1: タスク検出パターンの分析と強化

**goal**: 見逃しケースを減らすためにパターンを強化

#### subtasks

- [ ] **p1.1**: 現在のタスク検出パターンを確認
  - executor: claudecode
  - test_command: `grep -q "WORK_PATTERNS" .claude/hooks/prompt-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "現在のパターンを確認: 作って|実装して|追加して|修正して|変更して|削除して"
    - consistency: "見逃しケースを列挙"
    - completeness: "追加すべきパターンを特定"

- [ ] **p1.2**: タスク検出パターンを強化
  - executor: claudecode
  - test_command: `grep -q "直して\|なおして\|書いて\|作成" .claude/hooks/prompt-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "追加パターン: 直して|なおして|書いて|作成して|開発して|構築して"
    - consistency: "既存パターンとの重複を避ける"
    - completeness: "日本語・英語両方で網羅"

**status**: pending
**max_iterations**: 3

---

### p2: exit 2 への変更（ブロック化）

**goal**: 警告から構造的ブロックへ変更

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: playbook=null + タスク検出時に exit 2 を返すよう修正
  - executor: claudecode
  - test_command: `grep -A20 "WORK_PATTERNS" .claude/hooks/prompt-guard.sh | grep -q "exit 2" && echo PASS || echo FAIL`
  - validations:
    - technical: "タスク検出時に exit 2 でブロック"
    - consistency: "既存の State Injection は維持"
    - completeness: "ブロック時に stderr でメッセージ出力"

- [ ] **p2.2**: ブロックメッセージを充実させる
  - executor: claudecode
  - test_command: `grep -q "pm を呼び出" .claude/hooks/prompt-guard.sh && grep -q "exit 2" .claude/hooks/prompt-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "対処法が明記されている"
    - consistency: "CLAUDE.md Core Contract への参照がある"
    - completeness: "具体的なコマンド例が含まれている"

**status**: pending
**max_iterations**: 5

---

### p3: 非タスクプロンプトの許可

**goal**: 質問・議論系のプロンプトは許可されることを確認

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: 質問パターンの許可リストを追加
  - executor: claudecode
  - test_command: `grep -q "QUESTION_PATTERNS\|質問\|どう\|何" .claude/hooks/prompt-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "質問パターン: どうやって|何|なぜ|確認して|教えて|読んで"
    - consistency: "質問 + タスクパターンの両方を含む場合はブロック"
    - completeness: "純粋な質問は許可される"

- [ ] **p3.2**: discussion モードの確認
  - executor: claudecode
  - test_command: `grep -q "discussion" .claude/hooks/prompt-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "session: discussion の場合はタスク検出をスキップ"
    - consistency: "state.md の session フィールドを参照"
    - completeness: "discussion モードでは全てのプロンプトを許可"
  - note: "discussion モードが実装されていない場合は追加"

**status**: pending
**max_iterations**: 3

---

### p_final: 完了検証

**goal**: 修正が正しく動作することを検証

**depends_on**: [p3]

#### subtasks

- [ ] **p_final.1**: playbook=null + タスクプロンプトがブロックされる
  - executor: claudecode
  - test_command: `grep -A20 "WORK_PATTERNS" .claude/hooks/prompt-guard.sh | grep -q "exit 2" && echo PASS || echo FAIL`
  - validations:
    - technical: "タスク検出時に exit 2 を返すコードが存在する"
    - consistency: "エラーメッセージが出力される"
    - completeness: "ブロックが機能している"
  - note: "動作テストは手動で確認（state.md の playbook.active を変更するテストは危険）"

- [ ] **p_final.2**: 質問プロンプトは許可される
  - executor: claudecode
  - test_command: `echo '{"prompt":"このコードは何をしていますか"}' | bash .claude/hooks/prompt-guard.sh 2>&1; [ $? -eq 0 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "exit 0 が返される"
    - consistency: "State Injection は出力される"
    - completeness: "質問は許可されている"

- [ ] **p_final.3**: テストが全て PASS する
  - executor: claudecode
  - test_command: `bash scripts/flow-runtime-test.sh 2>&1 | grep -q "ALL.*PASS" && echo PASS || echo FAIL`
  - validations:
    - technical: "テストが正常に実行される"
    - consistency: "新機能が既存テストを破壊していない"
    - completeness: "主要テストが全て PASS"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## rollback

```yaml
手順:
  1. prompt-guard.sh を復元
     git checkout HEAD -- .claude/hooks/prompt-guard.sh

  2. state.md を復元（変更した場合）
     git checkout HEAD -- state.md
```

---

## notes

### 問題の詳細

```yaml
現状:
  - prompt-guard.sh は playbook=null + タスク検出時に警告を出す
  - しかし exit 0 で応答続行を許可
  - LLM が警告を無視して進める可能性

期待:
  - playbook=null + タスク検出時に exit 2 でブロック
  - LLM は pm を呼ぶまで応答できない
  - Core Contract の「playbook 必須」を構造的に強制
```

### 追加すべきパターン

```yaml
現在のパターン:
  - 作って|実装して|追加して|修正して|変更して|削除して
  - create|implement|add|fix|change|delete|update|edit|write

追加候補:
  日本語:
    - 直して|なおして|書いて|作成して|開発して|構築して
    - やって|してください|お願い
  英語:
    - build|develop|make|do|please

除外すべきパターン（質問）:
  - どうやって|何|なぜ|どこ|いつ|誰
  - how|what|why|where|when|who
  - 読んで|確認して|教えて|説明して
```

### discussion モード

```yaml
目的:
  - タスクではなく議論・質問のみのセッション
  - playbook なしでも会話を許可

設定:
  # state.md
  session: discussion  # task | discussion

動作:
  - discussion: タスク検出をスキップ
  - task: 通常のタスク検出
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
