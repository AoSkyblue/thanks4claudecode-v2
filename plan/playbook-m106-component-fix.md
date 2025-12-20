# playbook-m106-component-fix.md

> **M105 で特定された動作不良コンポーネント 3 件を修正**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/layer-architecture
created: 2025-12-20
issue: null
derives_from: M106
reviewed: true  # 2025-12-20 reviewer PASS (minor issues noted)
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: M105 で特定された動作不良コンポーネント 3 件を修正し、回帰テストを追加
done_when:
  - "consent-guard.sh のデッドロック問題が解消されている"
  - "critic-guard.sh が phase.status 変更を検出する"
  - "subtask-guard.sh がデフォルト STRICT=1 になっている"
  - "各修正に対する回帰テストが追加されている"
```

---

## 問題分析

### 1. consent-guard.sh - デッドロック問題（HIGH）

**現状の動作:**
- consent ファイルが存在する場合、Edit/Write をブロック
- ブロック時に [理解確認] を出力するよう案内
- 問題: consent ファイル削除のトリガーがない場合、永久にブロック

**問題点:**
- consent ファイルは session-start.sh が作成
- 削除は prompt-guard.sh が「OK」等のユーザー応答を検出時に実行
- しかし、Claude がすでに Edit を試行した後だと、ループに陥る可能性

**修正方針:**
- admin モードでは consent チェックを無効化（既に部分実装済み）
- consent ファイルの TTL（有効期限）を導入し、古いファイルは自動削除
- または playbook.active が存在する場合は consent 不要とする

### 2. critic-guard.sh - phase 完了チェック欠落（HIGH）

**現状の動作:**
- state.md の `state: done` 変更のみを検出
- playbook の phase.status 変更を検出しない

**問題点:**
- playbook で `status: done` に変更しても critic 呼び出しが強制されない
- subtask のチェックボックス変更のみ監視（subtask-guard）
- phase 全体の完了時に critic を強制する仕組みがない

**修正方針:**
- playbook ファイルの `**status**: done` 変更も検出対象に追加
- または subtask-guard.sh で phase 完了検出を追加

### 3. subtask-guard.sh - デフォルト WARN モード（MEDIUM）

**現状の動作:**
- STRICT=0 がデフォルト（35行目: `STRICT_MODE="${STRICT:-0}"`）
- validations なしでも WARN のみで通過

**問題点:**
- 3 観点検証なしで subtask 完了が可能
- 報酬詐欺のリスクが残存

**修正方針:**
- デフォルトを STRICT=1 に変更
- playbook 作成時に validations を必須化

---

## phases

### p1: consent-guard.sh デッドロック修正

**goal**: consent-guard.sh のデッドロック問題を解消

#### subtasks

- [ ] **p1.1**: playbook.active が存在する場合は consent チェックをスキップする
  - executor: claudecode
  - test_command: `grep -q 'playbook.active' .claude/hooks/consent-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "state.md から playbook.active を正しく取得できる"
    - consistency: "他の Hook の playbook チェックロジックと統一されている"
    - completeness: "null/empty の場合のハンドリングが含まれている"

- [ ] **p1.2**: consent ファイルの TTL（1時間）を導入する
  - executor: claudecode
  - test_command: `grep -q 'find.*-mmin' .claude/hooks/consent-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "find コマンドの -mmin オプションが正しく使用されている"
    - consistency: "session-start.sh と整合している"
    - completeness: "古いファイル削除のロジックが含まれている"

- [ ] **p1.3**: 修正後に bash -n で構文エラーがない
  - executor: claudecode
  - test_command: `bash -n .claude/hooks/consent-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "bash 構文エラーがない"
    - consistency: "シェルスクリプト規約に準拠"
    - completeness: "全パスが正しく閉じている"

**status**: pending
**max_iterations**: 5

---

### p2: critic-guard.sh phase 完了チェック追加

**goal**: playbook の phase.status 変更を検出して critic 呼び出しを強制

#### subtasks

- [ ] **p2.1**: playbook ファイルの編集を検出対象に追加する
  - executor: claudecode
  - test_command: `grep -q 'playbook-' .claude/hooks/critic-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "playbook ファイルパスのパターンマッチが正しい"
    - consistency: "subtask-guard.sh の判定ロジックと統一されている"
    - completeness: "plan/ ディレクトリ外の playbook も考慮"

- [ ] **p2.2**: `**status**: done` への変更を検出する
  - executor: claudecode
  - test_command: `grep -qE 'status.*done|\\*\\*status\\*\\*.*done' .claude/hooks/critic-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "Markdown 太字形式の status を正しくマッチする"
    - consistency: "playbook-format.md の形式と一致"
    - completeness: "大文字小文字の揺れを考慮"

- [ ] **p2.3**: critic 未実行時に警告メッセージを出力する
  - executor: claudecode
  - test_command: `bash -n .claude/hooks/critic-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "構文エラーがない"
    - consistency: "他の Hook の警告フォーマットと統一"
    - completeness: "ブロックと警告の両方のパスが実装"

**status**: pending
**max_iterations**: 5
**depends_on**: [p1]

---

### p3: subtask-guard.sh デフォルト STRICT=1 変更

**goal**: subtask-guard.sh のデフォルトを STRICT=1 に変更

#### subtasks

- [ ] **p3.1**: STRICT_MODE のデフォルト値を 1 に変更する
  - executor: claudecode
  - test_command: `grep -q 'STRICT:-1' .claude/hooks/subtask-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "デフォルト値が 1 に設定されている"
    - consistency: "ドキュメントと一致している"
    - completeness: "環境変数 STRICT=0 でオーバーライド可能"

- [ ] **p3.2**: bash -n で構文エラーがない
  - executor: claudecode
  - test_command: `bash -n .claude/hooks/subtask-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "構文エラーがない"
    - consistency: "他の Hook と同じ構文規約"
    - completeness: "全分岐パスが正しく閉じている"

**status**: pending
**max_iterations**: 3
**depends_on**: [p2]

---

### p4: 回帰テスト追加

**goal**: 各修正に対する回帰テストをスクリプトに追加

#### subtasks

- [ ] **p4.1**: scripts/test-hooks.sh に consent-guard のテストを追加する
  - executor: claudecode
  - test_command: `grep -q 'consent-guard' scripts/test-hooks.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "テストケースが正しく定義されている"
    - consistency: "他のテストケースと同じフォーマット"
    - completeness: "デッドロック回避の検証が含まれている"

- [ ] **p4.2**: scripts/test-hooks.sh に critic-guard のテストを追加する
  - executor: claudecode
  - test_command: `grep -q 'critic-guard.*phase' scripts/test-hooks.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "テストケースが正しく定義されている"
    - consistency: "他のテストケースと同じフォーマット"
    - completeness: "playbook phase 検出の検証が含まれている"

- [ ] **p4.3**: scripts/test-hooks.sh に subtask-guard STRICT=1 のテストを追加する
  - executor: claudecode
  - test_command: `grep -q 'subtask-guard.*STRICT' scripts/test-hooks.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "テストケースが正しく定義されている"
    - consistency: "他のテストケースと同じフォーマット"
    - completeness: "STRICT=1 デフォルト動作の検証が含まれている"

- [ ] **p4.4**: 全テストが PASS する
  - executor: claudecode
  - test_command: `bash scripts/test-hooks.sh 2>&1 | tail -5 | grep -q 'ALL.*PASS' && echo PASS || echo FAIL`
  - validations:
    - technical: "全テストが正常に実行される"
    - consistency: "テスト結果フォーマットが統一されている"
    - completeness: "3 コンポーネント全てのテストが含まれている"

**status**: pending
**max_iterations**: 5
**depends_on**: [p3]

---

### p_final: 完了検証

**goal**: playbook の done_when が全て満たされているか最終検証

#### subtasks

- [ ] **p_final.1**: consent-guard.sh のデッドロック問題が解消されている
  - executor: claudecode
  - test_command: `grep -q 'playbook.active' .claude/hooks/consent-guard.sh && bash -n .claude/hooks/consent-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "playbook.active チェックが実装されている"
    - consistency: "他の Hook と同じチェックロジック"
    - completeness: "デッドロック回避策が完全に実装されている"

- [ ] **p_final.2**: critic-guard.sh が phase.status 変更を検出する
  - executor: claudecode
  - test_command: `grep -q 'phase' .claude/hooks/critic-guard.sh && grep -q 'playbook' .claude/hooks/critic-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "phase と playbook の両方のパターンが含まれている"
    - consistency: "project.md M106 の done_when と一致"
    - completeness: "全ての検出パターンが実装されている"

- [ ] **p_final.3**: subtask-guard.sh がデフォルト STRICT=1 になっている
  - executor: claudecode
  - test_command: `grep -q 'STRICT:-1' .claude/hooks/subtask-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "デフォルト値が正しく設定されている"
    - consistency: "project.md M106 の done_when と一致"
    - completeness: "オーバーライド機能も維持されている"

- [ ] **p_final.4**: 各修正に対する回帰テストが追加されている
  - executor: claudecode
  - test_command: `grep -c 'consent-guard\|critic-guard\|subtask-guard' scripts/test-hooks.sh | awk '{if($1>=3) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "3 コンポーネント全てのテストが存在する"
    - consistency: "テストフォーマットが統一されている"
    - completeness: "各コンポーネントに対応するテストがある"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: repository-map.yaml を更新する
  - command: `bash .claude/hooks/generate-repository-map.sh`
  - status: pending

- [ ] **ft2**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-20 | 初版作成。M106 動作不良コンポーネント修正 playbook。 |
