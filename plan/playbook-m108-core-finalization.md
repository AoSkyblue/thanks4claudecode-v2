# playbook-m108-core-finalization.md

> **動線単位認識の埋め込みとコア機能確定**
>
> M107 の教訓: パターンマッチは動線テストではない。
> 真のコア確定は「動線単位」で行う。

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/layer-architecture
created: 2025-12-20
derives_from: M108
reviewed: false
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: 動線単位の認識を永続化し、コア機能を確定する

done_when:
  # p1: 動線単位認識の埋め込み
  - "[ ] core-manifest.yaml v3 が動線ベースで再構成されている"
  - "[ ] session-start.sh が動線単位の認識を表示する"

  # p2: コア機能確定
  - "[ ] Core Functions が動線単位で定義されている"
  - "[ ] Quality Functions が動線単位で定義されている"
  - "[ ] Extension Functions が動線単位で定義されている"

  # p_final: ドキュメント化
  - "[ ] docs/core-functions.md にコア機能リストが記載されている"
  - "[ ] 全ての変更がコミットされている"

test_commands:
  - "test -f governance/core-manifest.yaml && grep -q 'version: 3' governance/core-manifest.yaml && echo PASS || echo FAIL"
  - "test -f docs/core-functions.md && echo PASS || echo FAIL"
```

---

## 動線単位認識（CRITICAL - この理解が全ての基盤）

```yaml
核心的理解:
  問題: コンポーネント単位（Hook/SubAgent/Skill）で考えると混乱する
  解決: 動線単位（計画/実行/検証/完了）で考える

動線とは:
  計画動線: ユーザー要求 → pm → playbook → state.md
  実行動線: playbook → Edit/Write → Guard発火
  検証動線: /crit → critic → done_criteria検証
  完了動線: phase完了 → アーカイブ → 次タスク導出

Layer分類の基準（動線単位）:
  Core: 計画動線 + 検証動線（ないと破綻）
  Quality: 実行動線（ないと品質低下）
  Extension: 完了動線 + 共通基盤（手動代替可）
```

---

## phases

### p1: 動線単位認識の埋め込み

**goal**: 動線単位の考え方を永続化する

#### subtasks

- [ ] **p1.1**: core-manifest.yaml v3 を動線ベースで再構成
  - executor: claudecode
  - test_command: `grep -q 'version: 3' governance/core-manifest.yaml && echo PASS || echo FAIL`
  - content:
    - version: 3
    - 動線ベースの Layer 構造
    - Core = 計画動線 + 検証動線
    - Quality = 実行動線
    - Extension = 完了動線 + 共通
  - validations:
    - technical: "YAML として有効"
    - consistency: "layer-architecture-design.md と整合"
    - completeness: "全コンポーネントが配置されている"

- [ ] **p1.2**: session-start.sh に動線単位の認識を追加
  - executor: claudecode
  - test_command: `grep -q '動線単位' .claude/hooks/session-start.sh && echo PASS || echo FAIL`
  - content:
    - 「全コンポーネントは動線単位で扱うこと」の表示
    - 4動線の簡易リマインダー
  - validations:
    - technical: "bash -n OK"
    - consistency: "既存機能を破壊しない"
    - completeness: "動線単位の認識が表示される"

**status**: pending
**max_iterations**: 3

---

### p2: コア機能確定

**goal**: 動線単位でコア機能を確定する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: Core Functions 定義（計画動線 + 検証動線）
  - executor: claudecode
  - content:
    計画動線 Core:
      - prompt-guard.sh: タスク検出、pm必須警告
      - /task-start: 起点コマンド
      - pm.md: playbook作成
      - state skill: state.md管理
      - plan-management skill: 運用ガイド

    検証動線 Core:
      - /crit: 検証起点
      - critic.md: done_criteria検証
      - critic-guard.sh: critic PASS必須
  - validations:
    - technical: "動線単位で定義されている"
    - consistency: "layer-architecture-design.md と整合"
    - completeness: "各動線に必須コンポーネントがある"

- [ ] **p2.2**: Quality Functions 定義（実行動線）
  - executor: claudecode
  - content:
    実行動線 Quality:
      - init-guard.sh: 必須ファイル Read強制
      - playbook-guard.sh: playbook存在チェック
      - subtask-guard.sh: 3観点検証
      - check-protected-edit.sh: HARD_BLOCK
      - pre-bash-check.sh: 危険コマンドブロック
      - consent-guard.sh: 危険操作同意
      - scope-guard.sh: done_criteria変更検出
  - validations:
    - technical: "実行動線のみで構成"
    - consistency: "Core Contract と整合"
    - completeness: "全ガードが含まれている"

- [ ] **p2.3**: Extension Functions 定義（完了動線 + 共通）
  - executor: claudecode
  - content:
    完了動線:
      - archive-playbook.sh
      - cleanup-hook.sh
      - create-pr-hook.sh
      - post-loop skill
      - context-management skill

    共通基盤:
      - session-start.sh
      - session-end.sh
      - pre-compact.sh
      - log-subagent.sh

    横断的:
      - check-coherence.sh
      - depends-check.sh
      - lint-check.sh
  - validations:
    - technical: "手動代替可能なもののみ"
    - consistency: "Core/Quality に該当しない"
    - completeness: "残り全てがここに配置"

**status**: pending
**max_iterations**: 2

---

### p_final: ドキュメント化

**goal**: コア機能リストをドキュメント化

**depends_on**: [p2]

#### subtasks

- [ ] **p_final.1**: docs/core-functions.md 作成
  - executor: claudecode
  - test_command: `test -f docs/core-functions.md && echo PASS || echo FAIL`
  - content:
    - 動線単位の認識ルール
    - Core Functions リスト（計画動線 + 検証動線）
    - Quality Functions リスト（実行動線）
    - Extension Functions リスト（完了動線 + 共通）
    - Layer判定基準
  - validations:
    - technical: "Markdown として有効"
    - consistency: "core-manifest.yaml v3 と整合"
    - completeness: "全40コンポーネントが分類されている"

- [ ] **p_final.2**: 変更をコミット
  - executor: claudecode
  - command: `git add -A && git commit -m "feat(M108): finalize core functions based on flow architecture"`
  - validations:
    - technical: "コミット成功"
    - consistency: "全ファイルが含まれている"
    - completeness: "M108 完了"

**status**: pending
**max_iterations**: 2

---

## final_tasks

- [ ] **ft1**: state.md 更新
- [ ] **ft2**: project.md M108 status 更新

---

## notes

- **動線単位**: 全てのコンポーネントは動線で扱う。Hook/SubAgent という分類は二次的。
- **Core = 破綻防止**: 計画動線 + 検証動線がないとシステム破綻。
- **Quality = 品質保証**: 実行動線がないと品質低下するが動く。
- **Extension = 便利機能**: 完了動線 + 共通は手動代替可能。
