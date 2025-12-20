# playbook-m118-document-core-context.md

> **M118: ドキュメントのコアコンテキスト化**
>
> ドキュメントを動線の一部として「構造的に参照される」ようにする

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/layer-architecture
created: 2025-12-21
issue: null
derives_from: M118
reviewed: true
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: ドキュメントを動線の一部として構造的に参照されるようにする
done_when:
  - governance/context-manifest.yaml が存在し、動線別のコアドキュメントが定義されている
  - pm.md が計画動線のコアドキュメントを必ず Read するよう指示されている
  - critic.md が検証動線のコアドキュメントを必ず Read するよう指示されている
  - session-start.sh が動線別のコアドキュメント一覧を出力している
```

---

## phases

### p1: コンテキストマニフェスト設計

**goal**: governance/context-manifest.yaml を作成し、動線別のコアドキュメントを定義する

#### subtasks

- [ ] **p1.1**: governance/context-manifest.yaml が存在する
  - executor: claudecode
  - test_command: `test -f governance/context-manifest.yaml && echo PASS || echo FAIL`
  - validations:
    - technical: "YAML として構文エラーがない"
    - consistency: "docs/flow-document-map.md と整合している"
    - completeness: "4動線 + 共通基盤のコアドキュメントが定義されている"

- [ ] **p1.2**: context-manifest.yaml に Core Context（常に参照）が定義されている
  - executor: claudecode
  - test_command: `grep -q 'core_context:' governance/context-manifest.yaml && echo PASS || echo FAIL`
  - validations:
    - technical: "CLAUDE.md, state.md, plan/project.md が含まれている"
    - consistency: "現在の運用と一致している"
    - completeness: "必須の3ファイルが含まれている"

- [ ] **p1.3**: context-manifest.yaml に Flow Context（動線別）が定義されている
  - executor: claudecode
  - test_command: `grep -c 'planning:\|execution:\|verification:\|completion:' governance/context-manifest.yaml | awk '{if($1>=4) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "4動線が定義されている"
    - consistency: "docs/flow-document-map.md の分類と一致している"
    - completeness: "各動線に必要なドキュメントが含まれている"

**status**: pending
**max_iterations**: 5

---

### p2: SubAgent の更新

**goal**: pm.md と critic.md を更新し、コアドキュメントの Read を必須化する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: pm.md に計画動線のコアドキュメント Read 指示が追加されている
  - executor: claudecode
  - test_command: `grep -q 'context-manifest.yaml\|計画動線.*Read' .claude/agents/pm.md && echo PASS || echo FAIL`
  - validations:
    - technical: "pm.md の構文が正しい"
    - consistency: "context-manifest.yaml の計画動線と一致している"
    - completeness: "ai-orchestration.md, playbook-schema-v2.md, criterion-validation-rules.md が含まれている"

- [ ] **p2.2**: critic.md に検証動線のコアドキュメント Read 指示が追加されている
  - executor: claudecode
  - test_command: `grep -q 'context-manifest.yaml\|検証動線.*Read' .claude/agents/critic.md && echo PASS || echo FAIL`
  - validations:
    - technical: "critic.md の構文が正しい"
    - consistency: "context-manifest.yaml の検証動線と一致している"
    - completeness: "verification-criteria.md, criterion-validation-rules.md が含まれている"

**status**: pending
**max_iterations**: 5

---

### p3: session-start.sh の更新

**goal**: session-start.sh を更新し、動線別のコアドキュメント一覧を出力する

**depends_on**: [p1]

#### subtasks

- [ ] **p3.1**: session-start.sh が context-manifest.yaml を読み込んでいる
  - executor: claudecode
  - test_command: `grep -q 'context-manifest.yaml' .claude/hooks/session-start.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "bash -n session-start.sh でエラーがない"
    - consistency: "context-manifest.yaml のパスが正しい"
    - completeness: "読み込みロジックが存在する"

- [ ] **p3.2**: session-start.sh の出力に動線別コアドキュメントが含まれている
  - executor: claudecode
  - test_command: `bash .claude/hooks/session-start.sh 2>&1 | grep -q '計画動線\|実行動線\|検証動線\|完了動線' && echo PASS || echo FAIL`
  - validations:
    - technical: "出力フォーマットが正しい"
    - consistency: "context-manifest.yaml の定義と一致している"
    - completeness: "4動線のドキュメントが出力されている"

**status**: pending
**max_iterations**: 5

---

### p_final: 完了検証（必須）

**goal**: done_when が全て満たされているか最終検証

**depends_on**: [p1, p2, p3]

#### subtasks

- [ ] **p_final.1**: governance/context-manifest.yaml が存在し、動線別のコアドキュメントが定義されている
  - executor: claudecode
  - test_command: `test -f governance/context-manifest.yaml && grep -c 'planning:\|execution:\|verification:\|completion:' governance/context-manifest.yaml | awk '{if($1>=4) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "ファイルが存在し、構文エラーがない"
    - consistency: "docs/flow-document-map.md と整合している"
    - completeness: "全動線のコアドキュメントが定義されている"

- [ ] **p_final.2**: pm.md が計画動線のコアドキュメントを必ず Read するよう指示されている
  - executor: claudecode
  - test_command: `grep -qE 'ai-orchestration|playbook-schema|criterion-validation' .claude/agents/pm.md && echo PASS || echo FAIL`
  - validations:
    - technical: "pm.md が正しく更新されている"
    - consistency: "context-manifest.yaml と一致している"
    - completeness: "3つの計画動線ドキュメントが参照されている"

- [ ] **p_final.3**: critic.md が検証動線のコアドキュメントを必ず Read するよう指示されている
  - executor: claudecode
  - test_command: `grep -qE 'verification-criteria|criterion-validation' .claude/agents/critic.md && echo PASS || echo FAIL`
  - validations:
    - technical: "critic.md が正しく更新されている"
    - consistency: "context-manifest.yaml と一致している"
    - completeness: "2つの検証動線ドキュメントが参照されている"

- [ ] **p_final.4**: session-start.sh が動線別のコアドキュメント一覧を出力している
  - executor: claudecode
  - test_command: `bash .claude/hooks/session-start.sh 2>&1 | grep -qE '計画動線|Flow Context' && echo PASS || echo FAIL`
  - validations:
    - technical: "session-start.sh が正常に動作する"
    - consistency: "context-manifest.yaml の定義と一致している"
    - completeness: "動線別ドキュメントが出力に含まれている"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git commit -m "feat(M118): add context manifest for document core context"`
  - status: pending

- [ ] **ft2**: main ブランチにマージする
  - command: `git checkout main && git merge feat/layer-architecture --no-edit`
  - status: pending
  - note: playbook.active 設定中に実行必須

- [ ] **ft3**: フィーチャーブランチを削除する
  - command: `git branch -d feat/layer-architecture`
  - status: pending

- [ ] **ft4**: playbook をアーカイブする
  - command: `mkdir -p plan/archive && mv plan/playbook-m118-document-core-context.md plan/archive/`
  - status: pending

- [ ] **ft5**: state.md を更新する
  - command: `# playbook.active を null に、last_archived を更新`
  - status: pending

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成。M118 ドキュメントのコアコンテキスト化。 |
