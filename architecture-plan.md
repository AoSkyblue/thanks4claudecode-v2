# 計画階層構造

```mermaid
flowchart TB
    subgraph PlanHierarchy["計画階層（6層）"]
        direction TB
        V["vision.md<br/>WHY-ultimate<br/>完成形ビジョン"]
        MR["meta-roadmap.md<br/>HOW-to-improve<br/>仕組み改善計画"]
        CTX["CONTEXT.md<br/>WHY<br/>設計思想"]
        RM["roadmap.md<br/>WHAT<br/>中長期計画"]
        PB["playbook<br/>HOW<br/>タスク計画"]
        TK["task<br/>DO<br/>実行"]

        V --> MR
        MR --> CTX
        CTX --> RM
        RM --> PB
        PB --> TK
    end

    subgraph MacroMediumMicro["3層計画構造"]
        direction TB
        MACRO["Macro<br/>plan/project.md<br/>リポジトリ全体の最終目標"]
        MEDIUM["Medium<br/>playbook-*.md<br/>1ブランチ=1playbook"]
        MICRO["Micro<br/>Phase<br/>1セッション単位"]

        MACRO --> MEDIUM
        MEDIUM --> MICRO
    end

    subgraph FocusLayers["Focus レイヤー（4層・作業場所）"]
        direction LR
        L1["plan-template<br/>状態: done<br/>テンプレート開発"]
        L2["workspace<br/>状態: done<br/>仕組み開発"]
        L3["setup<br/>状態: done<br/>環境構築案内"]
        L4["product<br/>状態: pending<br/>プロダクト開発"]

        L1 -->|作成順| L2
        L2 -->|作成順| L3
        L3 -->|使用順| L4
    end

    subgraph StateFlow["状態遷移フロー"]
        direction LR
        S1["pending"]
        S2["designing"]
        S3["implementing"]
        S4["reviewing"]
        S5["state_update"]
        S6["done"]

        S1 --> S2
        S2 --> S3
        S3 --> S4
        S4 --> S5
        S5 --> S6

        S1 -.-x|禁止| S3
        S1 -.-x|禁止| S6
        S3 -.-x|禁止| S6
    end

    subgraph CurrentState["現在の状態"]
        CS_F["focus.current: product"]
        CS_S["session: task"]
        CS_P["playbook: playbook-e2e-validation.md"]
        CS_B["branch: feat/e2e-validation"]
        CS_G["goal: Macro完了（done_when達成）"]
    end

    subgraph FourTuple["四つ組連動"]
        FT["focus ↔ state ↔ playbook ↔ branch<br/>これが壊れると全てが壊れる"]
    end

    %% 接続
    PlanHierarchy --> MacroMediumMicro
    MacroMediumMicro --> FocusLayers
    FocusLayers --> StateFlow
    CurrentState --> FourTuple
```

## 計画構造の説明

### 6層計画階層

| 層 | ファイル | 役割 |
|----|---------|------|
| 1 | vision.md | WHY-ultimate: 完成形ビジョン |
| 2 | meta-roadmap.md | HOW-to-improve: 仕組み改善計画 |
| 3 | CONTEXT.md | WHY: 設計思想 |
| 4 | roadmap.md | WHAT: 中長期計画 |
| 5 | playbook | HOW: タスク計画 |
| 6 | task | DO: 実行 |

### 3層計画構造（Macro/Medium/Micro）

| 層 | 単位 | ファイル |
|----|------|---------|
| Macro | リポジトリ全体 | plan/project.md |
| Medium | ブランチ単位 | playbook-*.md |
| Micro | セッション単位 | Phase |

### 4層 Focus レイヤー

| レイヤー | 目的 | 作成順 | 使用順 | 状態 |
|---------|------|-------|-------|------|
| plan-template | テンプレート開発 | 1 | 2 | done |
| workspace | 仕組み開発 | 2 | - | done |
| setup | 環境構築案内 | 3 | 1 | done |
| product | プロダクト開発 | - | 3 | pending |

### 状態遷移

```
pending → designing → implementing → reviewing → state_update → done
```

**禁止遷移**:
- pending → implementing（designing スキップ）
- pending → done（全スキップ）
- implementing → done（state_update スキップ）
