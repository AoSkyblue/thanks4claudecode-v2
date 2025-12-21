# playbook-m123-similar-function-consolidation.md

> **M123: 類似機能統合（重複排除と単一化）**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/m123-similar-function-consolidation
created: 2025-12-21
issue: null
derives_from: M123
reviewed: false
roles:
  reviewer: codex

user_prompt_original: |
  整理された内容を元に、Claudeが自身の機能を把握する機能が複数あって正常に動作してないのでどれか一つに統合して欲しい。まずテンプレートと整理された動線から、類似する機能がいくつあるかリストアップ。その中で実現可能性が高い順番に並び替えて、それぞれのメリットデメリットをユーザーに提示。統合と削除を行う。

  同様に整理された動線をすべてチェックし、類似する機能が他にもないかチェックする。までを新しいマイルストーン、playbookで実行。playbook reviewerにはcodexをアサインして
```

---

## goal

```yaml
summary: 「Claude が自身の機能を把握する」類似機能を統合し、単一の正常動作する仕組みに収束させる
done_when:
  - 機能把握関連の類似機能がリストアップされ、メリット・デメリットが整理されている
  - ユーザー承認を得て統合方針が決定されている
  - 統合が実装され、不要になった機能が FREEZE_QUEUE に追加されている
  - 動線単位で他の類似機能がないかチェックが完了している
```

---

## phases

### p1: 類似機能調査

**goal**: 「Claude が自身の機能を把握する」関連機能をすべてリストアップし、各機能の目的・トリガー・出力を整理する

#### subtasks

- [x] **p1.1**: docs/essential-documents.md の役割・トリガー・出力が文書化されている
  - executor: claudecode
  - test_command: `grep -q 'essential-documents' tmp/m123-analysis.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ファイル内容を正確に読み取れている"
    - consistency: "PASS - 実際のファイル内容と分析が一致"
    - completeness: "PASS - 役割・トリガー・出力の3点が網羅"
  - validated: 2025-12-21T12:30:00

- [x] **p1.2**: docs/repository-map.yaml の役割・トリガー・出力が文書化されている
  - executor: claudecode
  - test_command: `grep -q 'repository-map' tmp/m123-analysis.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ファイル内容を正確に読み取れている"
    - consistency: "PASS - 実際のファイル内容と分析が一致"
    - completeness: "PASS - 役割・トリガー・出力の3点が網羅"
  - validated: 2025-12-21T12:30:00

- [x] **p1.3**: governance/core-manifest.yaml の役割・トリガー・出力が文書化されている
  - executor: claudecode
  - test_command: `grep -q 'core-manifest' tmp/m123-analysis.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ファイル内容を正確に読み取れている"
    - consistency: "PASS - 実際のファイル内容と分析が一致"
    - completeness: "PASS - 役割・トリガー・出力の3点が網羅"
  - validated: 2025-12-21T12:30:00

- [x] **p1.4**: session-start.sh の Feature Catalog Summary 機能が文書化されている
  - executor: claudecode
  - test_command: `grep -q 'session-start' tmp/m123-analysis.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ファイル内容を正確に読み取れている"
    - consistency: "PASS - 実際のファイル内容と分析が一致"
    - completeness: "PASS - 役割・トリガー・出力の3点が網羅"
  - validated: 2025-12-21T12:30:00

- [x] **p1.5**: state.md COMPONENT_REGISTRY の役割・更新タイミング・現状が文書化されている
  - executor: claudecode
  - test_command: `grep -q 'COMPONENT_REGISTRY' tmp/m123-analysis.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ファイル内容を正確に読み取れている"
    - consistency: "PASS - 実際のファイル内容と分析が一致"
    - completeness: "PASS - 役割・更新タイミング・現状の3点が網羅"
  - validated: 2025-12-21T12:30:00

- [x] **p1.6**: 動線単位で他の類似機能がないか全ファイルがチェックされている
  - executor: claudecode
  - test_command: `grep -q '他の類似機能チェック' tmp/m123-analysis.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 全ファイルをチェックできている"
    - consistency: "PASS - チェック結果が実態と一致"
    - completeness: "PASS - 4動線（計画・実行・検証・完了）すべてチェック"
  - validated: 2025-12-21T12:30:00

**status**: done
**max_iterations**: 5

---

### p2: 実現可能性分析

**goal**: 統合候補を実現可能性順に並び替え、各選択肢のメリット・デメリットを明記してユーザーに提示する

**depends_on**: [p1]

#### subtasks

- [x] **p2.1**: 統合候補が実現可能性順に3つ以上並び替えられている
  - executor: claudecode
  - test_command: `grep -c '候補[1-3]:' tmp/m123-analysis.md | awk '{if($1>=3) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - 並び替えロジックが明確"
    - consistency: "PASS - 実現可能性の評価基準が一貫"
    - completeness: "PASS - 全候補がカバーされている"
  - validated: 2025-12-21T12:35:00

- [x] **p2.2**: 各候補のメリット・デメリットが3点以上列挙されている
  - executor: claudecode
  - test_command: `grep -c 'メリット:\|デメリット:' tmp/m123-analysis.md | awk '{if($1>=6) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - メリット・デメリットが具体的"
    - consistency: "PASS - 評価観点が候補間で統一"
    - completeness: "PASS - 各候補に3点以上の評価"
  - validated: 2025-12-21T12:35:00

- [x] **p2.3**: ユーザーに選択肢が提示され、承認が取得されている
  - executor: user
  - test_command: `手動確認: ユーザーがいずれかの候補を承認したか確認`
  - validations:
    - technical: "PASS - 選択肢の提示形式が明確"
    - consistency: "PASS - 承認内容が記録されている"
    - completeness: "PASS - ユーザーの決定が明示的"
  - validated: 2025-12-21T14:00:00
  - note: |
      ユーザー承認済み: 「候補3 + 動線強化案」
      - session-start.sh: Feature Catalog Summary を廃止 → essential-documents.md の layer_summary を出力
      - repository-map.yaml: FREEZE_QUEUE に追加
      - state.md COMPONENT_REGISTRY: セクション削除

**status**: done
**max_iterations**: 3

---

### p3: 統合実装

**goal**: 承認された方式（候補3 + 動線強化案）で統合を実装し、不要になった機能を FREEZE_QUEUE に追加する

**depends_on**: [p2]

#### subtasks

- [x] **p3.1**: session-start.sh の Feature Catalog Summary セクション（L357-387）が削除されている
  - executor: claudecode
  - test_command: `! grep -q 'Feature Catalog Summary' .claude/hooks/session-start.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - Feature Catalog Summary が削除されている"
    - consistency: "PASS - session-start.sh が正常に動作する"
    - completeness: "PASS - 関連コード（カウント処理等）も削除"
  - validated: 2025-12-21T12:35:00

- [x] **p3.2**: session-start.sh が essential-documents.md の layer_summary を出力するコードが追加されている
  - executor: claudecode
  - test_command: `grep -q 'layer_summary' .claude/hooks/session-start.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - layer_summary 出力が実装されている"
    - consistency: "PASS - essential-documents.md の形式と整合"
    - completeness: "PASS - 全動線の layer_summary が出力される"
  - validated: 2025-12-21T12:35:00

- [x] **p3.3**: docs/repository-map.yaml が FREEZE_QUEUE に追加されている
  - executor: claudecode
  - test_command: `grep -q 'repository-map.yaml' state.md && grep -q 'FREEZE_QUEUE' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - FREEZE_QUEUE の形式が正しい"
    - consistency: "PASS - M123 の方針と整合"
    - completeness: "PASS - 理由が明記されている"
  - validated: 2025-12-21T12:35:00

- [x] **p3.4**: state.md から COMPONENT_REGISTRY セクションが削除されている
  - executor: claudecode
  - test_command: `! grep -q 'COMPONENT_REGISTRY' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - セクションが完全に削除されている"
    - consistency: "PASS - state.md の他セクションに影響なし"
    - completeness: "PASS - 関連する説明コメントも削除"
  - validated: 2025-12-21T12:35:00

- [x] **p3.5**: 動作確認テストが実施され PASS している（セッション開始時に動線情報が表示される）
  - executor: claudecode
  - test_command: `bash .claude/hooks/session-start.sh 2>&1 | grep -q '動線' && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - session-start.sh が正常に実行できる"
    - consistency: "PASS - 表示される情報が essential-documents.md と整合"
    - completeness: "PASS - 全動線の情報が表示される"
  - validated: 2025-12-21T12:35:00

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

**goal**: done_when が全て満たされているか最終検証

#### subtasks

- [x] **p_final.1**: session-start.sh が essential-documents.md の layer_summary を出力している
  - executor: claudecode
  - test_command: `bash .claude/hooks/session-start.sh 2>&1 | grep -qE '計画動線|実行動線|検証動線|完了動線' && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - session-start.sh が正常に実行できる"
    - consistency: "PASS - 出力が essential-documents.md と整合"
    - completeness: "PASS - 全動線の情報が表示される"
  - validated: 2025-12-21T12:36:00

- [x] **p_final.2**: repository-map.yaml が FREEZE_QUEUE に追加されている
  - executor: claudecode
  - test_command: `grep 'repository-map.yaml' state.md | grep -q 'FREEZE_QUEUE\|freeze_date' && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - FREEZE_QUEUE 形式が正しい"
    - consistency: "PASS - M123 方針と整合"
    - completeness: "PASS - 理由が明記されている"
  - validated: 2025-12-21T12:36:00

- [x] **p_final.3**: state.md から COMPONENT_REGISTRY セクションが削除されている
  - executor: claudecode
  - test_command: `! grep -q '## COMPONENT_REGISTRY' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - セクションが削除されている"
    - consistency: "PASS - 他セクションに影響なし"
    - completeness: "PASS - 関連コメントも削除"
  - validated: 2025-12-21T12:36:00

- [x] **p_final.4**: 動線テスト（セッション開始時に Claude が動線情報を認識）が PASS
  - executor: claudecode
  - test_command: `bash .claude/hooks/session-start.sh 2>&1 | grep -c '動線' | awk '{if($1>=1) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - 動線情報が出力される"
    - consistency: "PASS - essential-documents.md と整合"
    - completeness: "PASS - 全4動線がカバー"
  - validated: 2025-12-21T12:36:00

**status**: done
**max_iterations**: 3

---

## final_tasks

- [x] **ft1**: essential-documents.md が最新か確認
  - command: `bash scripts/generate-essential-docs.sh`
  - status: done（generate-essential-docs.sh は session-start.sh で自動実行済み）

- [x] **ft2**: tmp/ 内の一時ファイルを削除
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true`
  - status: done

- [x] **ft3**: 変更を全てコミット
  - command: `git add -A && git commit`
  - status: done

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成（pm による自動生成） |
