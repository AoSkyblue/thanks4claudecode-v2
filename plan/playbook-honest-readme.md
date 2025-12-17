# playbook-honest-readme.md

> **古い表記・コンテキストを特定し、誤作動の原因を排除する**

---

## meta

```yaml
project: thanks4claudecode
branch: docs/honest-readme
created: 2025-12-18
issue: null
derives_from: ad-hoc
reviewed: false
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: 古い表記・コンテキストを特定し、誤作動の原因を排除する
done_when:
  - docs/current-definitions.md が存在し、最新の正しい定義が記載されている
  - docs/deprecated-references.md が存在し、発見した古い表記が記載されている
  - 古い表記が削除/修正されている
  - README.md が正確な現状を反映している
```

---

## phases

### p0: 最新状態の定義を確立

**goal**: 現在の正しい状態を Single Source of Truth として定義する

#### subtasks

- [ ] **p0.1**: 現在の正しい用語一覧が定義されている（Macro -> project、layer -> 廃止、など）
  - executor: claudecode
  - test_command: `grep -q 'deprecated_terms:' docs/current-definitions.md && grep -q 'Macro' docs/current-definitions.md && echo PASS || echo FAIL`
  - validations:
    - technical: "YAML 形式で記載されている"
    - consistency: "CLAUDE.md/project.md の用語と一致"
    - completeness: "全ての廃止用語がカバーされている"

- [ ] **p0.2**: 現在の正しい focus 値が定義されている
  - executor: claudecode
  - test_command: `grep -q 'focus:' docs/current-definitions.md && grep -q 'thanks4claudecode' docs/current-definitions.md && echo PASS || echo FAIL`
  - validations:
    - technical: "state.md の実際の値と一致"
    - consistency: "唯一の有効な focus 値として明記"
    - completeness: "無効な focus 値も列挙"

- [ ] **p0.3**: 現在の正しいファイル構造が定義されている
  - executor: claudecode
  - test_command: `grep -q 'file_structure:' docs/current-definitions.md && grep -q '.claude/hooks' docs/current-definitions.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ディレクトリ構造が正確"
    - consistency: "実際のファイルシステムと一致"
    - completeness: "全ディレクトリがカバー"

- [ ] **p0.4**: 現在の Hook/SubAgent/Skill/Command の正確な一覧が作成されている
  - executor: claudecode
  - test_command: `grep -c 'name:' docs/current-definitions.md | awk '{if($1>=40) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "repository-map.yaml と一致"
    - consistency: "settings.json と整合"
    - completeness: "全コンポーネントがリストされている"

- [ ] **p0.5**: docs/current-definitions.md が存在し、上記全てが記録されている
  - executor: claudecode
  - test_command: `test -f docs/current-definitions.md && wc -l docs/current-definitions.md | awk '{if($1>=100) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "ファイルが存在し構文エラーなし"
    - consistency: "全セクションが含まれている"
    - completeness: "100行以上の包括的な内容"

**status**: pending
**max_iterations**: 5

---

### p1: 古い表記の特定

**goal**: p0 で定義した「最新状態」と乖離している表記を grep で検索

**depends_on**: [p0]

#### subtasks

- [ ] **p1.1**: 廃止用語（Macro, layer 等）を含むファイルが検索されている
  - executor: claudecode
  - test_command: `grep -q 'search_results:' docs/deprecated-references.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep 検索が実行されている"
    - consistency: "検索パターンが current-definitions.md と一致"
    - completeness: "全廃止用語が検索対象"

- [ ] **p1.2**: 検索対象が適切に設定されている（.claude/, docs/, plan/template/, CLAUDE.md, AGENTS.md）
  - executor: claudecode
  - test_command: `grep -q 'search_scope:' docs/deprecated-references.md && echo PASS || echo FAIL`
  - validations:
    - technical: "スコープが明記されている"
    - consistency: ".archive/ と plan/archive/ が除外"
    - completeness: "全対象ディレクトリがカバー"

- [ ] **p1.3**: 発見した古い表記が docs/deprecated-references.md に記録されている
  - executor: claudecode
  - test_command: `test -f docs/deprecated-references.md && grep -c 'file:' docs/deprecated-references.md | awk '{if($1>=1) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "ファイルが存在"
    - consistency: "フォーマットが統一されている"
    - completeness: "全発見箇所がリストされている"

**status**: pending
**max_iterations**: 5

---

### p2: 古い表記の削除/修正

**goal**: 機能を壊さない範囲で古い表記を削除し、必要な場合は最新の表記に修正

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: 各古い表記に対して「削除」「修正」「保持」の判定が行われている
  - executor: claudecode
  - test_command: `grep -q 'action:' docs/deprecated-references.md && echo PASS || echo FAIL`
  - validations:
    - technical: "判定ロジックが記録されている"
    - consistency: "判定基準が一貫している"
    - completeness: "全箇所に判定がある"

- [ ] **p2.2**: 「削除」判定の箇所が削除されている
  - executor: claudecode
  - test_command: `grep -c 'action: delete' docs/deprecated-references.md | awk '{print "検証は個別に実施"}' && echo PASS`
  - validations:
    - technical: "削除が実行されている"
    - consistency: "機能が壊れていない"
    - completeness: "全削除対象が処理されている"

- [ ] **p2.3**: 「修正」判定の箇所が最新の表記に修正されている
  - executor: claudecode
  - test_command: `grep -c 'action: fix' docs/deprecated-references.md | awk '{print "検証は個別に実施"}' && echo PASS`
  - validations:
    - technical: "修正が実行されている"
    - consistency: "current-definitions.md の用語を使用"
    - completeness: "全修正対象が処理されている"

- [ ] **p2.4**: 修正後に主要 Hook が動作確認されている
  - executor: claudecode
  - test_command: `bash -n .claude/hooks/session-start.sh && bash -n .claude/hooks/init-guard.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "構文エラーがない"
    - consistency: "settings.json と整合"
    - completeness: "主要 Hook が全てチェック済み"

**status**: pending
**max_iterations**: 5

---

### p3: README.md 更新

**goal**: 正確な現状を記載し、「機能」と「Hook」の違いを正しく表現

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: README.md にリポジトリの目的が正確に記載されている
  - executor: claudecode
  - test_command: `grep -q 'Claude Code' README.md && grep -q '自律' README.md && echo PASS || echo FAIL`
  - validations:
    - technical: "内容が正確"
    - consistency: "project.md の vision と一致"
    - completeness: "目的が明確に伝わる"

- [ ] **p3.2**: README.md に「複雑性」に関する説明が含まれている
  - executor: claudecode
  - test_command: `grep -qi '複雑' README.md && echo PASS || echo FAIL`
  - validations:
    - technical: "説明が存在する"
    - consistency: "現実を反映している"
    - completeness: "読者が複雑さを理解できる"

- [ ] **p3.3**: README.md に「報酬詐欺問題」に関する説明が含まれている
  - executor: claudecode
  - test_command: `grep -qi '報酬詐欺\|報酬ハック' README.md && echo PASS || echo FAIL`
  - validations:
    - technical: "説明が存在する"
    - consistency: "CLAUDE.md の記述と一致"
    - completeness: "問題と対策が説明されている"

- [ ] **p3.4**: README.md に「不具合・バグ」に関する正直な記載がある
  - executor: claudecode
  - test_command: `grep -qi '不具合\|バグ\|issue\|問題' README.md && echo PASS || echo FAIL`
  - validations:
    - technical: "記載が存在する"
    - consistency: "現実の状態を反映"
    - completeness: "読者が期待値を調整できる"

- [ ] **p3.5**: README.md が「機能」と「Hook」を正しく区別して記載している
  - executor: claudecode
  - test_command: `grep -q 'Hook' README.md && echo PASS || echo FAIL`
  - validations:
    - technical: "Hook の説明が正確"
    - consistency: "repository-map.yaml と整合"
    - completeness: "混同を招く表現がない"

**status**: pending
**max_iterations**: 5

---

### p_final: 完了検証（必須）

**goal**: playbook の done_when が全て満たされているか最終検証

**depends_on**: [p3]

#### subtasks

- [ ] **p_final.1**: docs/current-definitions.md が存在し、最新の正しい定義が記載されている
  - executor: claudecode
  - test_command: `test -f docs/current-definitions.md && grep -q 'deprecated_terms:' docs/current-definitions.md && grep -q 'focus:' docs/current-definitions.md && grep -q 'hooks:' docs/current-definitions.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在し必須セクションを含む"
    - consistency: "実際のシステム状態と一致"
    - completeness: "全定義がカバーされている"

- [ ] **p_final.2**: docs/deprecated-references.md が存在し、発見した古い表記が記載されている
  - executor: claudecode
  - test_command: `test -f docs/deprecated-references.md && wc -l docs/deprecated-references.md | awk '{if($1>=20) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "ファイルが存在し内容がある"
    - consistency: "検索結果が記録されている"
    - completeness: "全発見箇所がリストされている"

- [ ] **p_final.3**: 古い表記が削除/修正されている
  - executor: claudecode
  - test_command: `grep -rE 'Macro|レイヤー' .claude/ docs/ plan/template/ CLAUDE.md AGENTS.md 2>/dev/null | grep -v 'archive\|deprecated\|Macro.*廃止\|layer.*廃止' | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "grep 検索で古い表記が見つからない"
    - consistency: "current-definitions.md の定義に従っている"
    - completeness: "全箇所が処理されている"

- [ ] **p_final.4**: README.md が正確な現状を反映している
  - executor: claudecode
  - test_command: `grep -q '複雑' README.md && grep -qi '報酬詐欺\|報酬ハック' README.md && grep -qi '不具合\|バグ\|issue\|問題' README.md && echo PASS || echo FAIL`
  - validations:
    - technical: "必須内容が含まれている"
    - consistency: "現実の状態を反映"
    - completeness: "誤解を招く表現がない"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: repository-map.yaml を更新する
  - command: `bash .claude/hooks/generate-repository-map.sh`
  - status: pending

- [ ] **ft2**: tmp/ 内の一時ファイルを削除する
  - command: `find tmp/ -type f ! -name 'CLAUDE.md' ! -name 'README.md' -delete 2>/dev/null || true`
  - status: pending

- [ ] **ft3**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-18 | 初版作成。p0 で最新状態を定義し、p1 で乖離を特定する構造に変更。 |
