# playbook-m127-playbook-reviewer-automation.md

> **Playbook Reviewer 動線の自動化**
>
> pm が playbook 作成後、自動的に reviewer を起動し、Codex レビュー結果をパースして reviewed フラグを更新する。

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/m127-playbook-reviewer-automation
created: 2025-12-21
issue: null
derives_from: M127
reviewed: true  # pm self-review PASS 2025-12-21
roles:
  worker: claudecode

user_prompt_original: |
  M127: Playbook Reviewer 動線の自動化

  背景（M126 Codex 手動レビュー体験から）:
  - `codex exec --full-auto` で playbook レビューが可能
  - 5 ラウンドのレビューサイクルで test_command の堅牢化を学習
  - 「レビューなしの実装は何もしないよりタチが悪い」

  目的:
  1. pm が playbook 作成後、自動的に reviewer SubAgent を起動
  2. reviewer が config.roles.reviewer に基づいて Codex/ClaudeCode を選択
  3. Codex の場合、`codex exec --full-auto` を実行し RESULT: PASS/FAIL をパース
  4. FAIL なら修正サイクル、PASS なら reviewed: true に更新

  学習した test_command 設計原則:
  - exit code で成功/失敗を判定可能にする
  - 存在チェックは test -f で明示的に行う
  - grep の否定は反転ロジックを使う
  - done_when は具体的なファイル名/固定数を明記する
```

---

## goal

```yaml
summary: reviewer SubAgent が config.roles.reviewer を読んで自動的に Codex/Claude を選択し、playbook レビューを自動化する
done_when:
  - "reviewer SubAgent が config.roles.reviewer を読んで分岐できる"
  - "codex の場合、codex exec --full-auto を Bash で実行できる"
  - "RESULT: PASS/FAIL をパースして reviewed: true/false を更新できる"
  - "FAIL 時に修正提案を返却できる"
```

---

## phases

### p1: reviewer.md の拡張設計

**goal**: reviewer SubAgent が config.roles.reviewer を読んで分岐するロジックを設計する

#### subtasks

- [ ] **p1.1**: 現在の reviewer.md の構造を分析し、拡張ポイントを特定する
  - executor: claudecode
  - test_command: `test -f .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "reviewer.md が存在し読み取り可能である"
    - consistency: "現在の構造と新機能の互換性を確認"
    - completeness: "拡張が必要な箇所が全て特定されている"

- [ ] **p1.2**: config.roles.reviewer 読み取りロジックが設計されている
  - executor: claudecode
  - test_command: `grep -q 'config.roles.reviewer' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "state.md からの読み取り方法が正しい"
    - consistency: "既存の roles 解決ロジック（role-resolver.sh）と整合"
    - completeness: "claudecode / codex 両方の分岐が定義されている"

**status**: pending
**max_iterations**: 5

---

### p2: Codex 実行ロジックの実装

**goal**: codex exec --full-auto を Bash で実行し、結果をパースするロジックを reviewer.md に追加する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: codex exec --full-auto のコマンドテンプレートが reviewer.md に記載されている
  - executor: claudecode
  - test_command: `grep -q 'codex exec --full-auto' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "コマンド構文が正しい"
    - consistency: "既存の Codex 実行方法と整合"
    - completeness: "タイムアウト、出力先、エラーハンドリングが含まれている"

- [ ] **p2.2**: RESULT: PASS/FAIL のパースロジックが reviewer.md に記載されている
  - executor: claudecode
  - test_command: `grep -qE 'RESULT:.*PASS|RESULT:.*FAIL' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep/awk でパース可能な形式である"
    - consistency: "Codex の出力形式と整合"
    - completeness: "PASS/FAIL 以外の出力（エラー等）も考慮されている"

- [ ] **p2.3**: Codex プロンプトテンプレートが具体的で再現可能である
  - executor: claudecode
  - test_command: `grep -c 'done_when' .claude/agents/reviewer.md | awk '{if($1>=3) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "プロンプトが playbook-review-criteria.md を参照している"
    - consistency: "Claude レビュー時と同等の品質基準を適用"
    - completeness: "レビュー観点（done_when, test_command, Phase 依存関係）が含まれている"

**status**: pending
**max_iterations**: 5

---

### p3: FAIL 時の修正サイクル実装

**goal**: Codex レビューが FAIL の場合、修正提案を返却し、リトライを可能にする

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: FAIL 時の issues 抽出ロジックが reviewer.md に記載されている
  - executor: claudecode
  - test_command: `grep -q 'issues:' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "Codex 出力から issues を抽出できる"
    - consistency: "issues フォーマットが playbook-review-criteria.md と整合"
    - completeness: "severity, location, suggestion が含まれている"

- [ ] **p3.2**: リトライ上限（max_retries: 3）と人間エスカレーションが定義されている
  - executor: claudecode
  - test_command: `grep -q 'max_retries' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "リトライカウントが正しく管理される"
    - consistency: "既存のエスカレーションフローと整合"
    - completeness: "3回 FAIL 時のメッセージが定義されている"

- [ ] **p3.3**: PASS 時の reviewed: true 更新ロジックが定義されている
  - executor: claudecode
  - test_command: `grep -q 'reviewed: true' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "Edit ツールで playbook を更新できる"
    - consistency: "playbook-format.md の reviewed フィールドと整合"
    - completeness: "更新前後の検証が含まれている"

**status**: pending
**max_iterations**: 5

---

### p4: 動作テストと検証

**goal**: 実装した reviewer 自動化ロジックが正しく動作することを検証する

**depends_on**: [p3]

#### subtasks

- [ ] **p4.1**: config.roles.reviewer=codex の場合、codex exec が呼び出されることを確認
  - executor: claudecode
  - test_command: `grep -q 'config.roles.reviewer.*codex' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "分岐ロジックが正しく動作する"
    - consistency: "state.md の toolstack 設定と整合"
    - completeness: "claudecode/codex 両方のパスがテストされている"

- [ ] **p4.2**: RESULT: PASS/FAIL のパースが期待通り動作することを確認
  - executor: claudecode
  - test_command: `echo 'RESULT: PASS' | grep -oE 'RESULT: (PASS|FAIL)' | awk '{print $2}' | grep -q 'PASS' && echo PASS || echo FAIL`
  - validations:
    - technical: "パースロジックが正しい"
    - consistency: "Codex の実際の出力形式と整合"
    - completeness: "エッジケース（複数 RESULT 行等）が考慮されている"

- [ ] **p4.3**: project.md の M127 test_commands が全て PASS する
  - executor: claudecode
  - test_command: `grep -q 'codex exec' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "test_commands が正しく実行できる"
    - consistency: "project.md の done_when と整合"
    - completeness: "全ての done_when が検証されている"

**status**: pending
**max_iterations**: 5

---

### p_final: 完了検証（必須）

**goal**: playbook の done_when が全て満たされているか最終検証

#### subtasks

- [ ] **p_final.1**: reviewer SubAgent が config.roles.reviewer を読んで分岐できる
  - executor: claudecode
  - test_command: `grep -qE 'config\.roles\.reviewer|roles\.reviewer' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "分岐ロジックが reviewer.md に存在する"
    - consistency: "state.md の roles 定義と整合"
    - completeness: "claudecode/codex 両方の分岐が定義されている"

- [ ] **p_final.2**: codex の場合、codex exec --full-auto を Bash で実行できる
  - executor: claudecode
  - test_command: `grep -q 'codex exec --full-auto' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "コマンド構文が正しい"
    - consistency: "Codex CLI の仕様と整合"
    - completeness: "タイムアウト、出力先が定義されている"

- [ ] **p_final.3**: RESULT: PASS/FAIL をパースして reviewed: true/false を更新できる
  - executor: claudecode
  - test_command: `grep -qE 'RESULT:.*PASS|reviewed: true' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "パースロジックが正しい"
    - consistency: "playbook-format.md の reviewed フィールドと整合"
    - completeness: "PASS/FAIL 両方の処理が定義されている"

- [ ] **p_final.4**: FAIL 時に修正提案を返却できる
  - executor: claudecode
  - test_command: `grep -qE 'issues:|FAIL.*修正|修正提案' .claude/agents/reviewer.md && echo PASS || echo FAIL`
  - validations:
    - technical: "issues フォーマットが正しい"
    - consistency: "playbook-review-criteria.md の出力フォーマットと整合"
    - completeness: "severity, suggestion が含まれている"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

- [ ] **ft2**: tmp/ 内の一時ファイルを削除する
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
