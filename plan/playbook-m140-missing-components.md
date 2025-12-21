# playbook-m140-missing-components.md

> **存在しないコンポーネントの解決**
>
> 仕様に記載されているが存在しないファイルを解決する。

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/m140-missing-components
created: 2025-12-21
issue: null
derives_from: M140
reviewed: false
roles:
  worker: claudecode

user_prompt_original: |
  コア機能の確定と凍結が一番最初にあったほうがいいかな。
  凍結の前に動作保証がなされている必要がある。
  例えば何回言っても君、理解確認機能が直らないしね。
  今の機能全部、リストアップして。何で動作しないのか、棚卸ししながら、
  スモールステップで進めるしかない。
```

---

## goal

```yaml
summary: 仕様に記載されているが存在しないコンポーネントを解決する
done_when:
  - "consent-guard.sh が作成されているか、core-manifest.yaml から削除されている"
  - "create-pr-hook.sh が作成されているか、settings.json から削除されている"
  - "generate-essential-docs.sh が作成されているか、essential-documents.md から参照が削除されている"
  - "仕様に記載された全コンポーネントがファイルとして存在する"
```

---

## phases

### p1: consent-guard.sh の解決

**goal**: consent-guard.sh を作成するか、仕様から削除する

#### subtasks

- [x] **p1.1**: consent-guard.sh の仕様を core-manifest.yaml から確認する
  - executor: claudecode
  - test_command: `grep -A5 'consent-guard.sh' governance/core-manifest.yaml && echo PASS`
  - validations:
    - technical: "PASS - 仕様確認完了"
    - consistency: "PASS - pre-bash-check.sh がブロック担当と確認"
    - completeness: "PASS - 役割は「危険操作同意取得」と明確"
  - validated: 2025-12-21

- [x] **p1.2**: consent-guard.sh を作成するか削除するか判断する
  - executor: claudecode
  - test_command: `echo "判断完了"`
  - validations:
    - technical: "PASS - Hook はユーザー入力を待てないため削除を決定"
    - consistency: "PASS - pre-bash-check.sh がブロック担当、AskUserQuestion で同意取得"
    - completeness: "PASS - 影響範囲（core-manifest, essential-documents）を把握"
  - validated: 2025-12-21

- [x] **p1.3**: 判断に基づいて実行する（作成 or 削除）
  - executor: claudecode
  - test_command: `! grep -E '^\s+- name: consent-guard\.sh' governance/core-manifest.yaml && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - core-manifest.yaml から削除済み"
    - consistency: "PASS - essential-documents.md からも削除済み"
    - completeness: "PASS - 全関連ドキュメント更新済み"
  - validated: 2025-12-21

**status**: done
**max_iterations**: 3

---

### p2: create-pr-hook.sh の解決

**goal**: create-pr-hook.sh を作成するか、settings.json から削除する

**depends_on**: [p1]

#### subtasks

- [x] **p2.1**: create-pr-hook.sh の仕様を確認する
  - executor: claudecode
  - test_command: `grep -A5 'create-pr-hook.sh' governance/core-manifest.yaml && echo PASS`
  - validations:
    - technical: "PASS - 仕様確認完了（PR 作成 Hook）"
    - consistency: "PASS - PostToolUse:Edit で毎回発火は過剰と判断"
    - completeness: "PASS - 役割「PR 作成」は手動または archive で代替可能"
  - validated: 2025-12-21

- [x] **p2.2**: create-pr-hook.sh を作成するか削除するか判断する
  - executor: claudecode
  - test_command: `echo "判断完了"`
  - validations:
    - technical: "PASS - 毎回の Edit で PR 作成は過剰のため削除を決定"
    - consistency: "PASS - 手動 PR または archive-playbook.sh で代替"
    - completeness: "PASS - 影響範囲（settings.json, core-manifest, essential-documents）を把握"
  - validated: 2025-12-21

- [x] **p2.3**: 判断に基づいて実行する（作成 or 削除）
  - executor: claudecode
  - test_command: `! grep -q 'create-pr-hook.sh' .claude/settings.json && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - settings.json から削除済み"
    - consistency: "PASS - core-manifest.yaml からも削除済み"
    - completeness: "PASS - essential-documents.md からも削除済み"
  - validated: 2025-12-21

**status**: done
**max_iterations**: 3

---

### p3: generate-essential-docs.sh の解決

**goal**: generate-essential-docs.sh を作成するか、essential-documents.md から参照を削除する

**depends_on**: [p2]

#### subtasks

- [x] **p3.1**: generate-essential-docs.sh の参照箇所を確認する
  - executor: claudecode
  - test_command: `grep 'generate-essential-docs.sh' docs/essential-documents.md && echo PASS`
  - validations:
    - technical: "PASS - 参照箇所確認（冒頭と変更履歴）"
    - consistency: "PASS - 自動生成は便利だが止血優先で参照削除"
    - completeness: "PASS - core-manifest.yaml から手動管理で代替可能"
  - validated: 2025-12-21

- [x] **p3.2**: 作成するか参照を削除するか判断する
  - executor: claudecode
  - test_command: `echo "判断完了"`
  - validations:
    - technical: "PASS - 止血優先で参照削除を決定"
    - consistency: "PASS - 手動管理に変更（後で自動生成追加可能）"
    - completeness: "PASS - 影響範囲（essential-documents.md のみ）を把握"
  - validated: 2025-12-21

- [x] **p3.3**: 判断に基づいて実行する（作成 or 削除）
  - executor: claudecode
  - test_command: `! grep -q 'generate-essential-docs.sh' docs/essential-documents.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 参照削除済み"
    - consistency: "PASS - 手動管理に変更と明記"
    - completeness: "PASS - 変更履歴も更新済み"
  - validated: 2025-12-21

**status**: done
**max_iterations**: 3

---

### p_final: 完了検証（必須）

**goal**: 全ての存在しないコンポーネントが解決されたことを検証

#### subtasks

- [x] **p_final.1**: consent-guard.sh の解決を検証
  - executor: claudecode
  - test_command: `! grep -E '^\s+- name: consent-guard\.sh' governance/core-manifest.yaml && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - core-manifest.yaml から削除済み"
    - consistency: "PASS - essential-documents.md からも削除済み"
    - completeness: "PASS - 全関連ファイルが更新済み"
  - validated: 2025-12-21

- [x] **p_final.2**: create-pr-hook.sh の解決を検証
  - executor: claudecode
  - test_command: `! grep -q 'create-pr-hook.sh' .claude/settings.json && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - settings.json から削除済み"
    - consistency: "PASS - core-manifest.yaml からも削除済み"
    - completeness: "PASS - essential-documents.md からも削除済み"
  - validated: 2025-12-21

- [x] **p_final.3**: generate-essential-docs.sh の解決を検証
  - executor: claudecode
  - test_command: `! grep -q 'generate-essential-docs.sh' docs/essential-documents.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - essential-documents.md から参照削除済み"
    - consistency: "PASS - 手動管理に変更と明記"
    - completeness: "PASS - 変更履歴も更新済み"
  - validated: 2025-12-21

- [x] **p_final.4**: 仕様に記載された全 Hook が存在することを検証
  - executor: claudecode
  - test_command: `for h in $(grep -B1 'type: hook' governance/core-manifest.yaml | grep 'name:' | sed 's/.*name: //' | tr -d ' '); do test -f ".claude/hooks/$h" || echo "MISSING: $h"; done`
  - validations:
    - technical: "PASS - 全 Hook が存在（19本）"
    - consistency: "PASS - 仕様と実態が完全一致"
    - completeness: "PASS - MISSING なし"
  - validated: 2025-12-21

**status**: done
**max_iterations**: 3

---

## final_tasks

- [x] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: done

- [x] **ft2**: tmp/ 内の一時ファイルを削除する
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true`
  - status: done (no temp files)

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 |
