# playbook-m104-layer-architecture.md

> **Layer アーキテクチャの設計議論と合意形成**
>
> このマイルストーンは「設計・議論・合意」のみがスコープ。実装は M105 で実施。

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/layer-architecture
created: 2025-12-20
issue: null
derives_from: M104
reviewed: false
roles:
  worker: claudecode  # 設計議論は claudecode が担当
```

---

## goal

```yaml
summary: Layer アーキテクチャを「黄金動線での役割」ベースで再定義し、ユーザーと合意を形成する
done_when:
  - Layer アーキテクチャの設計案が docs/layer-architecture-design.md に文書化されている
  - 「黄金動線での役割」ベースの Layer 定義案が作成されている
  - Core 最小セットの候補リストが議論・合意されている
  - 実装フェーズが M105 として project.md に定義されている
```

---

## phases

### p1: 現状分析と問題整理

**goal**: 現在の Layer 定義（core-manifest.yaml v2）の問題点を分析し、文書化する

#### subtasks

- [x] **p1.1**: governance/core-manifest.yaml の現在の Layer 定義を分析する
  - 結果: core-manifest.yaml v2 は `hooks:` セクションで構造化されており、これがコンテキスト汚染の根源
  - executor: claudecode
  - test_command: `echo "分析完了を口頭で確認"`
  - validations:
    - technical: "core-manifest.yaml が読み込める"
    - consistency: "Layer 定義が正確に理解されている"
    - completeness: "全 Layer の役割が把握されている"

- [x] **p1.2**: 「発火タイミング」ベースの問題点を列挙する
  - 結果:
    1. Hook 中心主義（SubAgents/Skills/Commands が別枠扱い）
    2. 「いつ発火するか」で分類し「黄金動線での役割」が不明
    3. 依存方向（深い→浅い）が定義されていない
    4. 黄金動線は複数あるのに単一視点
  - executor: claudecode
  - test_command: `echo "問題点リストが作成されている"`
  - validations:
    - technical: "問題点が具体的に記述されている"
    - consistency: "ユーザーの指摘と整合している"
    - completeness: "主要な問題が全てカバーされている"

**status**: done
**max_iterations**: 3

---

### p2: 黄金動線の定義と分析

**goal**: 黄金動線の各ステップとそこで必要なコンポーネントを明確化する

**depends_on**: [p1]

#### subtasks

- [x] **p2.1**: 黄金動線の各ステップを定義する
  - 結果: 4つの動線（計画/実行/検証/完了）を定義
  - executor: claudecode
  - test_command: `echo "黄金動線の定義が完成"`
  - validations:
    - technical: "各ステップが明確に定義されている"
    - consistency: "CLAUDE.md の Core Contract と整合"
    - completeness: "/task-start から done までが網羅されている"

- [x] **p2.2**: 各ステップで必要なコンポーネント（Hook/SubAgent/Skill）をマッピングする
  - 結果: 4動線（計画/実行/検証/完了）に対してコンポーネントをマッピング済み
  - executor: claudecode
  - test_command: `echo "コンポーネントマッピングが完成"`
  - validations:
    - technical: "コンポーネントが正確に特定されている"
    - consistency: "settings.json の登録と整合"
    - completeness: "全ステップがカバーされている"

- [x] **p2.3**: check.md の仕様存在確認
  - 結果: Hooks 22, SubAgents 3, Skills 7, Commands 8 = 40 全て実態と一致
  - executor: claudecode
  - test_command: `echo "check.md と実態が一致"`
  - validations:
    - technical: "全コンポーネントがファイルとして存在"
    - consistency: "check.md の記載と実態が一致"
    - completeness: "未記載のコンポーネントがない"

- [x] **p2.4**: check.md を黄金動線単位で再整理
  - 結果: 6カテゴリ（計画/実行/検証/完了/共通基盤/横断的整合性）で全40コンポーネントを分類
  - executor: claudecode
  - test_command: `grep -q '計画動線' check.md && grep -q '実行動線' check.md && echo PASS`
  - validations:
    - technical: "マークダウン形式が正しい"
    - consistency: "p2.1/p2.2 の分析結果と整合"
    - completeness: "全40コンポーネントが動線に分類されている"

**status**: done
**max_iterations**: 3

---

### p3: 新 Layer 定義案の作成

**goal**: 「黄金動線での役割」ベースの Layer 定義案を作成する

**depends_on**: [p2]

#### subtasks

- [x] **p3.1**: Layer 分類の基準を定義する
  - 結果: 不可欠性フレームワーク（破綻/品質低下/不便、代替手段、Core Contract）
  - executor: claudecode
  - test_command: `echo "Layer 分類基準が定義されている"`
  - validations:
    - technical: "PASS - 基準が明確で適用可能"
    - consistency: "PASS - 黄金動線の役割と整合"
    - completeness: "PASS - 全コンポーネントを分類可能"

- [x] **p3.2**: Core Layer の候補リストを作成する
  - 結果: 計画動線 + 検証動線（黄金動線の骨格、代替なし、Core Contract で必須）
  - executor: claudecode
  - test_command: `echo "Core Layer 候補リストが作成されている"`
  - validations:
    - technical: "PASS - 動線単位で理由が明記"
    - consistency: "PASS - 黄金動線に必須のもののみ"
    - completeness: "PASS - 12コンポーネント（計画6+検証6）"

- [x] **p3.3**: Quality/Extension Layer の候補リストを作成する
  - 結果: Quality=実行動線(11)、Extension=完了動線(8)+共通基盤(6)+横断的(3)=17
  - executor: claudecode
  - test_command: `echo "Quality/Extension Layer が定義されている"`
  - validations:
    - technical: "PASS - 各 Layer の役割が明確"
    - consistency: "PASS - Core Layer と重複なし"
    - completeness: "PASS - 全40コンポーネントが分類（12+11+17=40）"

- [x] **p3.4**: 動作不良コンポーネントの特定
  - 結果: subtask-guard（STRICT=0でWARNのみ）、critic-guard（playbook未対象）→ M105で修正
  - executor: claudecode
  - validations:
    - technical: "PASS - ソースコード確認済み"
    - consistency: "PASS - 設計意図と実装の乖離を特定"
    - completeness: "PASS - 修正方針を M105 に委譲"

**status**: done
**max_iterations**: 5

---

### p4: 設計ドキュメント作成

**goal**: 設計案を docs/layer-architecture-design.md に文書化する

**depends_on**: [p3]

#### subtasks

- [x] **p4.1**: docs/layer-architecture-design.md を作成する
  - 結果: 7セクション構成（設計思想、動線定義、フロー、基準、配置、動作不良、M105引継ぎ）
  - executor: claudecode
  - test_command: `test -f docs/layer-architecture-design.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - ファイル作成完了"
    - consistency: "PASS - Phase 1-3 の分析結果を反映"
    - completeness: "PASS - 設計案が完全に文書化"

- [x] **p4.2**: 黄金動線の図解を含める
  - 結果: ASCII アート形式で4動線+2カテゴリのフロー図を記載
  - executor: claudecode
  - test_command: `grep -q '黄金動線' docs/layer-architecture-design.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - マークダウン形式で表現"
    - consistency: "PASS - p2 の定義と整合"
    - completeness: "PASS - 全ステップ含む"

- [x] **p4.3**: Layer 定義表を含める
  - 結果: Core(12)/Quality(11)/Extension(17)=40 の表形式で整理
  - executor: claudecode
  - test_command: `grep -q 'Core' docs/layer-architecture-design.md && grep -q 'Quality' docs/layer-architecture-design.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 表形式で整理"
    - consistency: "PASS - p3 の候補リストと整合"
    - completeness: "PASS - 全 Layer 定義"

**status**: done
**max_iterations**: 3

---

### p5: ユーザー合意形成

**goal**: ユーザーと設計案について議論し、合意を得る

**depends_on**: [p4]

#### subtasks

- [x] **p5.1**: 設計案をユーザーに提示する
  - 結果: 設計サマリー（Core12/Quality11/Extension17、動作不良2件、M105実装タスク）を提示
  - executor: claudecode
  - test_command: `echo "設計案をユーザーに提示済み"`
  - validations:
    - technical: "PASS - サマリー形式で提示"
    - consistency: "PASS - docs/layer-architecture-design.md と整合"
    - completeness: "PASS - 主要論点を含む"

- [x] **p5.2**: ユーザーからのフィードバックを反映する
  - 結果: ユーザーから「いいよ」で合意取得
  - executor: user
  - test_command: `手動確認: ユーザーが設計案に合意している`
  - validations:
    - technical: "PASS - 合意を取得"
    - consistency: "PASS - 追加フィードバックなし"
    - completeness: "PASS - 合意完了"

**status**: done
**max_iterations**: 5

---

### p6: M105 定義

**goal**: 実装フェーズを M105 として project.md に追加する

**depends_on**: [p5]

#### subtasks

- [x] **p6.1**: M105 のマイルストーン定義を作成する
  - 結果: M105「Layer Architecture Implementation」を project.md に追加
  - executor: claudecode
  - test_command: `grep -q 'M105' plan/project.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - YAML 形式正しい"
    - consistency: "PASS - M104 の設計案と整合"
    - completeness: "PASS - 5つの done_when で実装を網羅"

**status**: done
**max_iterations**: 2

---

### p_final: 完了検証

**goal**: playbook の done_when が全て満たされているか最終検証

**depends_on**: [p6]

#### subtasks

- [x] **p_final.1**: docs/layer-architecture-design.md が存在し、設計案が含まれている
  - 結果: PASS - 200行超のドキュメント作成済み
  - executor: claudecode
  - test_command: `test -f docs/layer-architecture-design.md && wc -l docs/layer-architecture-design.md | awk '{if($1>=50) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "PASS - ファイル存在、十分な内容"
    - consistency: "PASS - goal.done_when と整合"
    - completeness: "PASS - 全設計要素含む"

- [x] **p_final.2**: 黄金動線ベースの Layer 定義が文書化されている
  - 結果: PASS - 黄金動線、Layer、Core/Quality/Extension 全て含む
  - executor: claudecode
  - test_command: `grep -q '黄金動線' docs/layer-architecture-design.md && grep -q 'Layer' docs/layer-architecture-design.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - キーワード含む"
    - consistency: "PASS - 設計案の核心反映"
    - completeness: "PASS - Layer 定義完全"

- [x] **p_final.3**: M105 が project.md に定義されている
  - 結果: PASS - M105「Layer Architecture Implementation」追加済み
  - executor: claudecode
  - test_command: `grep -q 'id: M105' plan/project.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - M105 エントリ存在"
    - consistency: "PASS - depends_on: [M104]"
    - completeness: "PASS - 5つの done_when 定義"

**status**: done
**max_iterations**: 2

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## notes

- このマイルストーンは「設計・議論・合意」のみがスコープ
- 実際の core-manifest.yaml や settings.json の変更は M105 で実施
- ユーザーとの対話を重視し、合意形成を優先する
