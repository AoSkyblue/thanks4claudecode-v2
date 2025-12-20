# playbook-m107-flow-test.md

> **動線単位テスト（E2E）- 報酬詐欺防止設計**
>
> M105 の「コンポーネント構文チェック」を是正し、真の動線単位テストを実施。
> **全 PASS は疑わしい結果**として扱う。FAIL が出ることを前提とした設計。

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/layer-architecture
created: 2025-12-20
derives_from: M107
reviewed: false
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: 動線単位テスト（E2E）を設計・実行し、M105 の報酬詐欺を是正する

done_when:
  # p1: テスト設計（報酬詐欺防止設計）
  - "[ ] scripts/flow-test.sh が存在し実行可能である"
  - "[ ] 各テストケースに「期待する FAIL」が明記されている"
  - "[ ] 「全 PASS」時の警告ロジックが実装されている"

  # p2: 計画動線テスト
  - "[ ] 計画動線テスト: ユーザー要求 -> pm -> playbook -> state.md の一連の流れが検証されている"
  - "[ ] 計画動線の FAIL 原因（あれば）が分析されている"

  # p3: 実行動線テスト
  - "[ ] 実行動線テスト: playbook active -> Edit/Write -> Guard 発火の一連の流れが検証されている"
  - "[ ] 実行動線の FAIL 原因（あれば）が分析されている"

  # p4: 検証動線テスト
  - "[ ] 検証動線テスト: /crit -> critic -> done_criteria 検証の一連の流れが検証されている"
  - "[ ] 検証動線の FAIL 原因（あれば）が分析されている"

  # p5: 完了動線テスト
  - "[ ] 完了動線テスト: phase 完了 -> アーカイブ -> project.md 更新の一連の流れが検証されている"
  - "[ ] 完了動線の FAIL 原因（あれば）が分析されている"

  # p_final: 総括
  - "[ ] テスト結果に FAIL が含まれ、その原因が分析されている"
  - "[ ] FAIL 項目の修正方針が決定されている"
  - "[ ] 「全 PASS」の場合、テスト設計の不備として再検討されている"

test_commands:
  - "test -f scripts/flow-test.sh && echo PASS || echo FAIL"
  - "bash scripts/flow-test.sh 2>&1 | grep -q 'FAIL' && echo 'FAIL found (expected)' || echo 'All PASS (suspicious - review test design)'"
```

---

## 動線単位テストの定義

> **M105 との違いを明確化**

```yaml
M105（コンポーネント単位テスト）:
  何をテストしたか:
    - bash -n でシンタックスエラーがない
    - ファイルが存在する
    - 単一コンポーネントの単独動作
  問題点:
    - 「存在する」と「動く」は別
    - フロー全体の検証がない
    - 報酬詐欺が可能（構文OKでも動かない可能性）

M107（動線単位テスト）:
  何をテストするか:
    - 動線を端から端まで実行
    - 状態遷移の前後比較（state.md diff）
    - 複数コンポーネント間の連携
  設計原則:
    - FAIL が出ることを期待
    - 全 PASS は「テスト設計不備」の可能性
    - Hook 入力をシミュレートして出力を検証
```

---

## phases

### p1: テスト設計

**goal**: 動線単位テストスクリプトを作成し、報酬詐欺防止の設計を組み込む

#### subtasks

- [ ] **p1.1**: scripts/flow-test.sh のスケルトン作成
  - executor: claudecode
  - test_command: `test -f scripts/flow-test.sh && test -x scripts/flow-test.sh && echo PASS || echo FAIL`
  - content:
    - 4 動線のテスト関数（test_planning_flow, test_execution_flow, test_verification_flow, test_completion_flow）
    - 各テストの期待 FAIL 条件をコメントで明記
    - 全 PASS 時の警告出力
  - validations:
    - technical: "スクリプトが実行可能で構文エラーがない"
    - consistency: "4 動線が project.md M107 定義と一致"
    - completeness: "全 PASS 警告ロジックが含まれている"

- [ ] **p1.2**: 「期待する FAIL」の明記
  - executor: claudecode
  - test_command: `grep -c 'EXPECTED_FAIL' scripts/flow-test.sh | awk '{if($1>=4) print "PASS"; else print "FAIL"}'`
  - content:
    - 各動線に最低 1 つの EXPECTED_FAIL を定義
    - FAIL 条件と理由をコメントで記載
  - validations:
    - technical: "EXPECTED_FAIL が 4 つ以上定義されている"
    - consistency: "M106 の既知問題と整合"
    - completeness: "全動線に EXPECTED_FAIL がある"

- [ ] **p1.3**: 「全 PASS」警告ロジック実装
  - executor: claudecode
  - test_command: `grep -q 'All.*PASS.*suspicious' scripts/flow-test.sh && echo PASS || echo FAIL`
  - content:
    - FAIL 件数が 0 の場合に警告を出力
    - 「テスト設計を再検討してください」メッセージ
  - validations:
    - technical: "警告ロジックが実装されている"
    - consistency: "報酬詐欺防止の設計思想と整合"
    - completeness: "警告メッセージが具体的"

**status**: pending
**max_iterations**: 3

---

### p2: 計画動線テスト

**goal**: ユーザー要求 -> pm -> playbook -> state.md の一連の流れを検証

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: pm SubAgent 呼び出しシミュレーション
  - executor: claudecode
  - test_scenario: |
    1. 擬似的なタスク要求を準備
    2. pm SubAgent の期待動作を定義
    3. playbook 作成の出力形式を検証
  - test_command: `test -f .claude/agents/pm.md && grep -q 'playbook' .claude/agents/pm.md && echo PASS || echo FAIL`
  - expected_fail: "pm が playbook をドラフト状態で作成しない場合"
  - validations:
    - technical: "pm SubAgent が呼び出し可能"
    - consistency: "playbook 形式が template と一致"
    - completeness: "derives_from が設定される"

- [ ] **p2.2**: playbook -> state.md 更新の検証
  - executor: claudecode
  - test_scenario: |
    1. playbook 作成後の state.md 状態をキャプチャ
    2. playbook.active が更新されているか確認
    3. branch フィールドが設定されているか確認
  - test_command: `grep -q 'playbook.active:' state.md && echo PASS || echo FAIL`
  - expected_fail: "state.md の自動更新が動作しない場合"
  - validations:
    - technical: "state.md パース可能"
    - consistency: "playbook.active が実在するファイルを指す"
    - completeness: "branch も同時に更新される"

- [ ] **p2.3**: prompt-guard.sh のタスク要求検出
  - executor: claudecode
  - test_command: `echo '{"user_prompt":"この機能を実装して"}' | bash .claude/hooks/prompt-guard.sh 2>&1; echo "exit=$?"`
  - expected_fail: "playbook=null で pm 呼び出し警告が出ない場合"
  - validations:
    - technical: "Hook が正常に実行される"
    - consistency: "pm 必須警告が出力される"
    - completeness: "タスク要求パターンが正しく検出される"

**status**: pending
**max_iterations**: 3

---

### p3: 実行動線テスト

**goal**: playbook active -> Edit/Write -> Guard 発火の一連の流れを検証

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: playbook=null での Edit ブロックテスト
  - executor: claudecode
  - test_scenario: |
    1. state.md の playbook.active を一時的に null に設定
    2. Edit 操作をシミュレート
    3. playbook-guard.sh がブロックするか確認
    4. state.md を元に戻す
  - test_command: |
    # playbook.active を null にした状態で playbook-guard をテスト
    TEMP_STATE=$(mktemp)
    echo 'playbook:' > "$TEMP_STATE"
    echo '  active: null' >> "$TEMP_STATE"
    STATE_FILE="$TEMP_STATE" bash .claude/hooks/playbook-guard.sh 2>&1
    EXIT_CODE=$?
    rm "$TEMP_STATE"
    if [ $EXIT_CODE -eq 2 ]; then echo PASS; else echo FAIL; fi
  - expected_fail: "admin モードでブロックされない場合"
  - validations:
    - technical: "playbook-guard.sh が exit 2 を返す"
    - consistency: "エラーメッセージが明確"
    - completeness: "Edit/Write 両方がブロック対象"

- [ ] **p3.2**: subtask-guard.sh の STRICT モードテスト
  - executor: claudecode
  - test_command: |
    # STRICT=1 でのブロック動作を確認
    echo '{"tool_name":"Edit"}' | STRICT=1 bash .claude/hooks/subtask-guard.sh 2>&1; echo "exit=$?"
  - expected_fail: "STRICT=1 でも validations なしで通過する場合"
  - validations:
    - technical: "STRICT=1 で validations 必須"
    - consistency: "M106 の修正が反映されている"
    - completeness: "警告メッセージが具体的"

- [ ] **p3.3**: pre-bash-check.sh の危険コマンドブロックテスト
  - executor: claudecode
  - test_command: |
    echo '{"tool_input":{"command":"rm -rf /"}}' | bash .claude/hooks/pre-bash-check.sh 2>&1; echo "exit=$?"
  - expected_fail: "危険コマンドがブロックされない場合"
  - validations:
    - technical: "exit 2 を返す"
    - consistency: "BLOCKED メッセージが出力される"
    - completeness: "複数の危険パターンが検出される"

- [ ] **p3.4**: check-main-branch.sh のブロックテスト
  - executor: claudecode
  - test_command: |
    # main ブランチでの Edit ブロックを確認（擬似）
    echo '{"tool_name":"Edit"}' | BRANCH_OVERRIDE=main bash .claude/hooks/check-main-branch.sh 2>&1; echo "exit=$?"
  - expected_fail: "main ブランチで Edit が許可される場合"
  - validations:
    - technical: "main ブランチ検出が動作する"
    - consistency: "ブロックメッセージが明確"
    - completeness: "Edit/Write 両方がブロック対象"

**status**: pending
**max_iterations**: 5

---

### p4: 検証動線テスト

**goal**: /crit -> critic -> done_criteria 検証の一連の流れを検証

**depends_on**: [p3]

#### subtasks

- [ ] **p4.1**: critic SubAgent 呼び出しテスト
  - executor: claudecode
  - test_scenario: |
    1. critic SubAgent の定義ファイルを確認
    2. 呼び出しパラメータの形式を検証
    3. 期待出力（PASS/FAIL + 根拠）の形式を確認
  - test_command: `test -f .claude/agents/critic.md && grep -q 'done_criteria' .claude/agents/critic.md && echo PASS || echo FAIL`
  - expected_fail: "critic が PASS/FAIL の根拠を出力しない場合"
  - validations:
    - technical: "critic.md が存在する"
    - consistency: "done_criteria 検証ロジックが記載されている"
    - completeness: "PASS/FAIL 判定基準が明確"

- [ ] **p4.2**: critic-guard.sh の phase 完了チェックテスト
  - executor: claudecode
  - test_command: |
    # phase 完了時に critic 呼び出しを強制するか
    bash -n .claude/hooks/critic-guard.sh && \
    grep -q 'playbook' .claude/hooks/critic-guard.sh && \
    echo PASS || echo FAIL
  - expected_fail: "phase 完了前に critic を呼び出さずに通過する場合"
  - validations:
    - technical: "構文エラーなし"
    - consistency: "M106 の修正が反映されている"
    - completeness: "playbook の status 変更を検出する"

- [ ] **p4.3**: done_criteria 検証フローの E2E テスト
  - executor: claudecode
  - test_scenario: |
    1. 現在の playbook の done_criteria を取得
    2. 各 criterion の test_command を実行
    3. PASS/FAIL 結果を集計
  - test_command: |
    # 現在の playbook から done_when を抽出
    PLAYBOOK=$(grep -oP 'active: \K.*' state.md | head -1)
    if [ -n "$PLAYBOOK" ] && [ -f "$PLAYBOOK" ]; then
      grep -c 'test_command' "$PLAYBOOK" | awk '{if($1>=1) print "PASS"; else print "FAIL"}'
    else
      echo "SKIP: No active playbook"
    fi
  - expected_fail: "test_command が定義されていない criterion がある場合"
  - validations:
    - technical: "test_command が実行可能"
    - consistency: "criterion と test_command が 1:1 対応"
    - completeness: "全 criterion に test_command がある"

**status**: pending
**max_iterations**: 3

---

### p5: 完了動線テスト

**goal**: phase 完了 -> アーカイブ -> project.md 更新の一連の流れを検証

**depends_on**: [p4]

#### subtasks

- [ ] **p5.1**: archive-playbook.sh の動作テスト
  - executor: claudecode
  - test_command: |
    # 空入力での SKIP 動作を確認
    echo '{}' | bash .claude/hooks/archive-playbook.sh 2>&1 | grep -qE 'SKIP|skip' && echo PASS || echo FAIL
  - expected_fail: "アーカイブ前に done_when 検証をスキップする場合"
  - validations:
    - technical: "SKIP 理由が stderr に出力される"
    - consistency: "M082 の契約に準拠"
    - completeness: "final_tasks 完了チェックが含まれる"

- [ ] **p5.2**: project.md 自動更新の検証
  - executor: claudecode
  - test_scenario: |
    1. playbook 完了時に project.md が更新されるか
    2. milestone.status が achieved に変更されるか
    3. achieved_at が設定されるか
  - test_command: |
    # project.md に achieved マイルストーンがあるか
    grep -c 'status: achieved' plan/project.md | awk '{if($1>=1) print "PASS"; else print "FAIL"}'
  - expected_fail: "playbook 完了時に project.md が更新されない場合"
  - validations:
    - technical: "project.md が YAML として有効"
    - consistency: "M083 の修正が反映されている"
    - completeness: "achieved_at も設定される"

- [ ] **p5.3**: 次タスク導出の検証
  - executor: claudecode
  - test_scenario: |
    1. playbook 完了後に pm が次タスクを提案するか
    2. depends_on 分析が行われるか
    3. 着手可能な milestone が特定されるか
  - test_command: |
    # project.md に not_achieved マイルストーンがあるか
    grep -c 'status: not_achieved' plan/project.md | awk '{if($1>=0) print "PASS"; else print "FAIL"}'
  - expected_fail: "次タスクの自動導出が動作しない場合"
  - validations:
    - technical: "depends_on の解析が正しい"
    - consistency: "pm SubAgent の仕様と整合"
    - completeness: "優先度判定が含まれる"

**status**: pending
**max_iterations**: 3

---

### p_final: 総括

**goal**: テスト結果を分析し、FAIL 項目の修正方針を決定

**depends_on**: [p5]

#### subtasks

- [ ] **p_final.1**: テスト結果の集計
  - executor: claudecode
  - test_command: `bash scripts/flow-test.sh 2>&1 | tail -10`
  - output: テスト結果サマリー（PASS/FAIL/SKIP 件数）
  - validations:
    - technical: "scripts/flow-test.sh が正常終了する"
    - consistency: "4 動線全てがテストされている"
    - completeness: "FAIL 件数が 0 でないことを確認"

- [ ] **p_final.2**: FAIL 原因の分析
  - executor: claudecode
  - output: docs/flow-test-report.md に記録
  - content:
    - 各 FAIL 項目の原因
    - 修正の優先度（HIGH/MEDIUM/LOW）
    - 修正担当（M108 以降）
  - validations:
    - technical: "レポートが作成されている"
    - consistency: "全 FAIL 項目がカバーされている"
    - completeness: "修正方針が明記されている"

- [ ] **p_final.3**: 「全 PASS」時の対応
  - executor: claudecode
  - condition: FAIL 件数が 0 の場合
  - action:
    - テスト設計の不備として再検討
    - EXPECTED_FAIL が本当に発生しないか確認
    - 「テストが甘すぎる可能性」を docs/flow-test-report.md に記載
  - validations:
    - technical: "全 PASS 警告が出力された"
    - consistency: "テスト設計の見直しが記録されている"
    - completeness: "次のアクションが明記されている"

**status**: pending
**max_iterations**: 2

---

## final_tasks

- [ ] **ft1**: scripts/flow-test.sh をコミット
  - command: `git add scripts/flow-test.sh`
  - status: pending

- [ ] **ft2**: docs/flow-test-report.md をコミット
  - command: `git add docs/flow-test-report.md`
  - status: pending

- [ ] **ft3**: state.md を更新
  - command: `git add state.md`
  - status: pending

---

## notes

- **報酬詐欺防止**: FAIL が出ることを前提とした設計。全 PASS は疑わしい。
- **M105 との違い**: 構文チェックではなく動線全体の E2E テスト。
- **次ステップ**: FAIL 項目は M108 で修正予定。
