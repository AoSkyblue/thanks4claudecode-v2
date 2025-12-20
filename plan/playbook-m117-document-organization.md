# playbook-m117-document-organization.md

> **M117: ドキュメント整理と動線紐づけ**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: docs/document-organization
created: 2025-12-21
issue: null
derives_from: M117
reviewed: false
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: docs/ 内の全ファイル（30個）を評価し、廃棄/統合/維持に分類。動線マップを作成して管理を効率化する。
done_when:
  - "[x] docs/ 全ファイルが評価され廃棄/統合/維持に分類されている"
  - "[x] 動線マップ（docs/flow-document-map.md）が作成されている"
  - "[x] 統合対象ファイル7件が特定されている（実行は M118）"
  - "[x] 廃棄対象ファイル6件が特定されている（FREEZE_QUEUE 追加は M118）"
```

---

## phases

### p1: ドキュメントカタログ作成

**goal**: docs/ 内の全ファイルをリストアップし、目的・内容を簡潔に記録する

#### subtasks

- [x] **p1.1**: docs/ 内の全ファイル一覧を取得している
  - executor: claudecode
  - test_command: `ls docs/*.md docs/*.yaml 2>/dev/null | wc -l | awk '{if($1>=28) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - 30ファイルが認識されている"
    - consistency: "PASS - manual-patches ディレクトリを除外"
    - completeness: "PASS - 28個以上のファイルが認識されている"
  - validated: 2025-12-21T01:45:00

- [x] **p1.2**: 各ファイルの目的・内容が1行で記録されている
  - executor: claudecode
  - test_command: `test -f docs/document-catalog.md && wc -l docs/document-catalog.md | awk '{if($1>=30) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - カタログファイルが作成されている（200行以上）"
    - consistency: "PASS - 全ファイルがカタログに含まれている"
    - completeness: "PASS - 各ファイルに説明がある"
  - validated: 2025-12-21T01:45:00

**status**: done
**max_iterations**: 5

---

### p2: 評価と分類

**goal**: 各ドキュメントを「廃棄・統合・維持」に分類する

#### subtasks

- [x] **p2.1**: 分類基準が定義されている
  - executor: claudecode
  - test_command: `grep -q '廃棄基準\|統合基準\|維持基準' docs/document-catalog.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 3つの分類基準が明記されている"
    - consistency: "PASS - 基準が一貫している"
    - completeness: "PASS - 判定フローが明確"
  - validated: 2025-12-21T01:45:00

- [x] **p2.2**: 全ファイルに分類タグが付与されている
  - executor: claudecode
  - test_command: `grep -c 'DISCARD\|MERGE\|KEEP' docs/document-catalog.md | awk '{if($1>=28) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - 全ファイルにタグが付いている（30個以上）"
    - consistency: "PASS - DISCARD/MERGE/KEEP の3タグで統一"
    - completeness: "PASS - 分類漏れがない"
  - validated: 2025-12-21T01:45:00

**status**: done
**max_iterations**: 5

---

### p3: 動線マップ作成

**goal**: 維持するドキュメントを4つの動線に分類してマッピング

#### subtasks

- [x] **p3.1**: docs/flow-document-map.md が作成されている
  - executor: claudecode
  - test_command: `test -f docs/flow-document-map.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ファイルが存在する"
    - consistency: "PASS - 動線定義と整合している"
    - completeness: "PASS - 4つの動線 + 共通基盤セクションがある"
  - validated: 2025-12-21T01:45:00

- [x] **p3.2**: 計画動線のドキュメントがマッピングされている
  - executor: claudecode
  - test_command: `grep -q '計画動線' docs/flow-document-map.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 計画動線セクションが存在する"
    - consistency: "PASS - ai-orchestration, playbook-schema, criterion 関連が含まれる"
    - completeness: "PASS - 関連コンポーネントもマッピング"
  - validated: 2025-12-21T01:45:00

- [x] **p3.3**: 実行動線のドキュメントがマッピングされている
  - executor: claudecode
  - test_command: `grep -q '実行動線' docs/flow-document-map.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 実行動線セクションが存在する"
    - consistency: "PASS - hook-exit-code, hook-responsibilities, core-contract が含まれる"
    - completeness: "PASS - 11個の Guard Hook がマッピング"
  - validated: 2025-12-21T01:45:00

- [x] **p3.4**: 検証動線のドキュメントがマッピングされている
  - executor: claudecode
  - test_command: `grep -q '検証動線' docs/flow-document-map.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 検証動線セクションが存在する"
    - consistency: "PASS - verification-criteria, criterion-validation が含まれる"
    - completeness: "PASS - critic, reviewer 関連コンポーネントがマッピング"
  - validated: 2025-12-21T01:45:00

- [x] **p3.5**: 完了動線のドキュメントがマッピングされている
  - executor: claudecode
  - test_command: `grep -q '完了動線' docs/flow-document-map.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 完了動線セクションが存在する"
    - consistency: "PASS - folder-management, freeze-then-delete, git-operations が含まれる"
    - completeness: "PASS - archive, cleanup Hook がマッピング"
  - validated: 2025-12-21T01:45:00

**status**: done
**max_iterations**: 5

---

### p4: 統合・廃棄の実行

**goal**: 統合対象ファイルをマージし、廃棄対象を FREEZE_QUEUE に追加

> **Note**: 実際の統合・廃棄は M118 で実施予定。M117 は評価・分類・マッピングまでをスコープとする。

#### subtasks

- [x] **p4.1**: 統合対象ファイルが特定されている
  - executor: claudecode
  - test_command: `grep -c 'MERGE' docs/document-catalog.md | awk '{if($1>=1) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - MERGE タグのファイルが7件特定されている"
    - consistency: "PASS - 統合先が明記されている"
    - completeness: "PASS - アクションプランに統合手順が記載"
  - validated: 2025-12-21T01:50:00

- [x] **p4.2**: 廃棄対象ファイルが特定されている
  - executor: claudecode
  - test_command: `grep -c 'DISCARD' docs/document-catalog.md | awk '{if($1>=1) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - DISCARD タグのファイルが6件特定されている"
    - consistency: "PASS - freeze-then-delete プロセスに記載"
    - completeness: "PASS - 廃棄理由が明記されている"
  - validated: 2025-12-21T01:50:00

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証

**goal**: 全ての done_when が満たされていることを最終確認する

#### subtasks

- [x] **p_final.1**: docs/ 全ファイルが評価・分類されている
  - executor: claudecode
  - test_command: `test -f docs/document-catalog.md && grep -c 'DISCARD\|MERGE\|KEEP' docs/document-catalog.md | awk '{if($1>=28) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - カタログファイルが存在し分類が記録されている"
    - consistency: "PASS - 全30ファイルが分類されている"
    - completeness: "PASS - 漏れがない"
  - validated: 2025-12-21T01:50:00

- [x] **p_final.2**: 動線マップが作成されている
  - executor: claudecode
  - test_command: `test -f docs/flow-document-map.md && grep -c '動線' docs/flow-document-map.md | awk '{if($1>=4) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - マップファイルが存在する"
    - consistency: "PASS - 4つの動線 + 共通基盤が定義されている"
    - completeness: "PASS - ドキュメントとコンポーネントが正しく配置"
  - validated: 2025-12-21T01:50:00

- [x] **p_final.3**: 統合対象ファイルが特定されている
  - executor: claudecode
  - test_command: `grep -c 'MERGE' docs/document-catalog.md | awk '{if($1>=1) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - MERGE 対象7件が特定されている"
    - consistency: "PASS - 統合先が明記されている"
    - completeness: "PASS - 実行は M118 で実施"
  - validated: 2025-12-21T01:50:00

- [x] **p_final.4**: 廃棄対象ファイルが特定されている
  - executor: claudecode
  - test_command: `grep -c 'DISCARD' docs/document-catalog.md | awk '{if($1>=1) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - DISCARD 対象6件が特定されている"
    - consistency: "PASS - 廃棄理由が明記されている"
    - completeness: "PASS - FREEZE_QUEUE 追加は M118 で実施"
  - validated: 2025-12-21T01:50:00

**status**: done
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git commit -m "docs(M117): organize documents and create flow map"`
  - status: pending

- [ ] **ft2**: main ブランチにマージする
  - command: `git checkout main && git merge docs/document-organization --no-edit`
  - status: pending
  - note: playbook.active 設定中に実行必須

- [ ] **ft3**: フィーチャーブランチを削除する
  - command: `git branch -d docs/document-organization`
  - status: pending

- [ ] **ft4**: playbook をアーカイブする
  - command: `mkdir -p plan/archive && mv plan/playbook-m117-document-organization.md plan/archive/`
  - status: pending

- [ ] **ft5**: state.md を更新する
  - command: `# playbook.active を null に、last_archived を更新`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成。ドキュメント整理と動線紐づけ playbook。 |
