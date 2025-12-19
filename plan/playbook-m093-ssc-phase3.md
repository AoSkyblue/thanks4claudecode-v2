# playbook-m093-ssc-phase3.md

> **安全な進化システム (SSC Phase 3): Freeze-then-Delete プロセスの実装**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/m093-ssc-phase3
created: 2025-12-19
issue: null
derives_from: M093
reviewed: false
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: 非推奨ファイルの削除プロセスを安全に管理する Freeze-then-Delete システムを実装
done_when:
  - state.md に FREEZE_QUEUE セクションが存在する
  - state.md に DELETE_LOG セクションが存在する
  - scripts/freeze-file.sh が存在し実行可能である
  - scripts/delete-frozen.sh が存在し実行可能である
  - Freeze-then-Delete プロセスが文書化されている
```

---

## phases

### p1: state.md へのセクション追加

**goal**: FREEZE_QUEUE と DELETE_LOG セクションを state.md に追加する

#### subtasks

- [x] **p1.1**: state.md に FREEZE_QUEUE セクションが存在する
  - executor: claudecode
  - test_command: `grep -q 'FREEZE_QUEUE' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "FREEZE_QUEUE セクションが YAML 形式で記述されている"
    - consistency: "他のセクション（COMPONENT_REGISTRY, SPEC_SNAPSHOT）と同じ形式"
    - completeness: "queue 配列と説明コメントが含まれている"

- [x] **p1.2**: state.md に DELETE_LOG セクションが存在する
  - executor: claudecode
  - test_command: `grep -q 'DELETE_LOG' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "DELETE_LOG セクションが YAML 形式で記述されている"
    - consistency: "他のセクション（COMPONENT_REGISTRY, SPEC_SNAPSHOT）と同じ形式"
    - completeness: "log 配列と説明コメントが含まれている"

**status**: done
**max_iterations**: 5

---

### p2: freeze-file.sh の実装

**goal**: ファイルを FREEZE_QUEUE に追加するスクリプトを実装する
**depends_on**: [p1]

#### subtasks

- [x] **p2.1**: scripts/freeze-file.sh が存在する
  - executor: claudecode
  - test_command: `test -f scripts/freeze-file.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが scripts/ ディレクトリに存在する"
    - consistency: "他のスクリプト（test-*.sh）と同じディレクトリ構成"
    - completeness: "ファイルが作成されている"

- [x] **p2.2**: scripts/freeze-file.sh が実行可能である
  - executor: claudecode
  - test_command: `test -x scripts/freeze-file.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "実行権限（chmod +x）が設定されている"
    - consistency: "他のスクリプトと同じ権限設定"
    - completeness: "実行可能状態である"

- [x] **p2.3**: scripts/freeze-file.sh が bash -n で構文エラーなしである
  - executor: claudecode
  - test_command: `bash -n scripts/freeze-file.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "Bash 構文が正しい"
    - consistency: "シェルスクリプトとして有効"
    - completeness: "構文エラーが 0 件"

- [x] **p2.4**: scripts/freeze-file.sh がファイルパスを引数に取り FREEZE_QUEUE に追加する
  - executor: claudecode
  - test_command: `echo "test-freeze-target.txt" | bash scripts/freeze-file.sh --dry-run 2>&1 | grep -q 'FREEZE_QUEUE' && echo PASS || echo FAIL`
  - validations:
    - technical: "引数として渡されたファイルパスを処理できる"
    - consistency: "state.md の FREEZE_QUEUE セクションを更新する"
    - completeness: "freeze_date と reason を含むエントリを追加する"

**status**: done
**max_iterations**: 5

---

### p3: delete-frozen.sh の実装

**goal**: 凍結期間が過ぎたファイルを削除するスクリプトを実装する
**depends_on**: [p2]

#### subtasks

- [x] **p3.1**: scripts/delete-frozen.sh が存在する
  - executor: claudecode
  - test_command: `test -f scripts/delete-frozen.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが scripts/ ディレクトリに存在する"
    - consistency: "他のスクリプト（test-*.sh, freeze-file.sh）と同じディレクトリ構成"
    - completeness: "ファイルが作成されている"

- [x] **p3.2**: scripts/delete-frozen.sh が実行可能である
  - executor: claudecode
  - test_command: `test -x scripts/delete-frozen.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "実行権限（chmod +x）が設定されている"
    - consistency: "他のスクリプトと同じ権限設定"
    - completeness: "実行可能状態である"

- [x] **p3.3**: scripts/delete-frozen.sh が bash -n で構文エラーなしである
  - executor: claudecode
  - test_command: `bash -n scripts/delete-frozen.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "Bash 構文が正しい"
    - consistency: "シェルスクリプトとして有効"
    - completeness: "構文エラーが 0 件"

- [x] **p3.4**: scripts/delete-frozen.sh が凍結期間（デフォルト 7 日）を超えたファイルを検出する
  - executor: claudecode
  - test_command: `bash scripts/delete-frozen.sh --dry-run 2>&1 | grep -qE 'DELETE_LOG|No files|expired' && echo PASS || echo FAIL`
  - validations:
    - technical: "freeze_date から経過日数を計算できる"
    - consistency: "FREEZE_QUEUE の形式を正しくパースする"
    - completeness: "凍結期間設定（--days オプション）が存在する"

- [x] **p3.5**: scripts/delete-frozen.sh が削除したファイルを DELETE_LOG に記録する
  - executor: claudecode
  - test_command: `bash scripts/delete-frozen.sh --help 2>&1 | grep -qE 'DELETE_LOG|log' && echo PASS || echo FAIL`
  - validations:
    - technical: "削除したファイルの情報を DELETE_LOG に追加する"
    - consistency: "state.md の DELETE_LOG セクションを更新する"
    - completeness: "deleted_date, original_path, reason を記録する"

**status**: done
**max_iterations**: 5

---

### p4: ドキュメント作成

**goal**: Freeze-then-Delete プロセスを文書化する
**depends_on**: [p3]

#### subtasks

- [x] **p4.1**: docs/freeze-then-delete.md が存在する
  - executor: claudecode
  - test_command: `test -f docs/freeze-then-delete.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ドキュメントファイルが存在する"
    - consistency: "docs/ ディレクトリに配置されている"
    - completeness: "ファイルが作成されている"

- [x] **p4.2**: docs/freeze-then-delete.md に概要セクションが存在する
  - executor: claudecode
  - test_command: `grep -q '## 概要' docs/freeze-then-delete.md && echo PASS || echo FAIL`
  - validations:
    - technical: "概要セクションが存在する"
    - consistency: "Markdown 形式"
    - completeness: "Freeze-then-Delete の目的が説明されている"

- [x] **p4.3**: docs/freeze-then-delete.md に使用方法セクションが存在する
  - executor: claudecode
  - test_command: `grep -qE '## 使用方法|## Usage' docs/freeze-then-delete.md && echo PASS || echo FAIL`
  - validations:
    - technical: "使用方法セクションが存在する"
    - consistency: "Markdown 形式"
    - completeness: "freeze-file.sh と delete-frozen.sh の使い方が記載されている"

- [x] **p4.4**: docs/freeze-then-delete.md にプロセスフローが図示されている
  - executor: claudecode
  - test_command: `grep -qE 'freeze.*confirm.*delete|フロー|flow' docs/freeze-then-delete.md && echo PASS || echo FAIL`
  - validations:
    - technical: "3 段階プロセス（freeze -> confirm -> delete）が説明されている"
    - consistency: "他のドキュメントと同じスタイル"
    - completeness: "各段階の役割が明確"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証

**goal**: playbook の done_when が全て満たされているか最終検証

#### subtasks

- [x] **p_final.1**: state.md に FREEZE_QUEUE セクションが存在する
  - executor: claudecode
  - test_command: `grep -q 'FREEZE_QUEUE' state.md && grep -A5 'FREEZE_QUEUE' state.md | grep -q 'queue:' && echo PASS || echo FAIL`
  - validations:
    - technical: "FREEZE_QUEUE セクションが正しい形式で存在する"
    - consistency: "他のセクションと同じ YAML 形式"
    - completeness: "queue 配列が定義されている"

- [x] **p_final.2**: state.md に DELETE_LOG セクションが存在する
  - executor: claudecode
  - test_command: `grep -q 'DELETE_LOG' state.md && grep -A5 'DELETE_LOG' state.md | grep -q 'log:' && echo PASS || echo FAIL`
  - validations:
    - technical: "DELETE_LOG セクションが正しい形式で存在する"
    - consistency: "他のセクションと同じ YAML 形式"
    - completeness: "log 配列が定義されている"

- [x] **p_final.3**: scripts/freeze-file.sh が存在し実行可能である
  - executor: claudecode
  - test_command: `test -x scripts/freeze-file.sh && bash -n scripts/freeze-file.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "スクリプトが存在し、構文エラーがない"
    - consistency: "実行権限が設定されている"
    - completeness: "完全に動作するスクリプトである"

- [x] **p_final.4**: scripts/delete-frozen.sh が存在し実行可能である
  - executor: claudecode
  - test_command: `test -x scripts/delete-frozen.sh && bash -n scripts/delete-frozen.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "スクリプトが存在し、構文エラーがない"
    - consistency: "実行権限が設定されている"
    - completeness: "完全に動作するスクリプトである"

- [x] **p_final.5**: Freeze-then-Delete プロセスが文書化されている
  - executor: claudecode
  - test_command: `test -f docs/freeze-then-delete.md && wc -l docs/freeze-then-delete.md | awk '{if($1>=30) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "ドキュメントが存在する"
    - consistency: "30 行以上の説明がある"
    - completeness: "概要、使用方法、プロセスフローが含まれている"

**status**: done
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: repository-map.yaml を更新する
  - command: `bash .claude/hooks/generate-repository-map.sh`
  - status: pending

- [ ] **ft2**: tmp/ 内の一時ファイルを削除する
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true`
  - status: pending

- [ ] **ft3**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-19 | 初版作成（ドラフト） |
