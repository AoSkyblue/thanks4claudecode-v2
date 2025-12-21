# Layer Architecture Design - 黄金動線ベースの設計

> **M104 成果物**: 議論・設計・合意のドキュメント
>
> 実装は M105 で実施。

---

## 1. 設計思想

### 従来の問題（core-manifest.yaml v2）

- **Hook 中心主義**: Layer 0/1 を「Hooks の発火タイミング」で分類
- **コンテキスト汚染**: `hooks:` セクション構造が思考を Hook に引き戻す
- **全体像の欠如**: SubAgents/Skills/Commands が役割ベースで分類されていない

### 新しいアプローチ

- **動線単位**: 黄金動線を単位として Layer を定義
- **役割ベース**: 全コンポーネント（Hooks + SubAgents + Skills + Commands）を動線での役割で分類
- **深さ = 保護レベル**: Core（凍結）→ Quality（保護）→ Extension（柔軟）

---

## 2. 黄金動線の定義

### 4つの動線 + 2つのカテゴリ

```
┌─────────────────────────────────────────────────────────────┐
│                    黄金動線のループ                          │
│                                                             │
│   計画動線 ──→ 実行動線 ──→ 検証動線 ──→ 完了動線 ──┐      │
│       ↑                                            │      │
│       └────────────────────────────────────────────┘      │
│                                                             │
│   ┌─────────────────────────────────────────────────┐      │
│   │ 共通基盤: セッションのライフサイクル管理         │      │
│   │ 横断的整合性: 動線間の整合性保証                │      │
│   └─────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 各動線のフロー

### 3.1 計画動線（6 コンポーネント）

```
ユーザープロンプト
       ↓
  prompt-guard ── タスク検出、pm 必須警告
       ↓
  /task-start ── 起点コマンド
       ↓
      pm ──────── playbook 作成
       ↓
    state ─────── state.md 更新
       ↓
plan-management ─ 運用ガイド適用
       ↓
  playbook 完成 → 実行動線へ
```

### 3.2 実行動線（11 コンポーネント）

```
  playbook 読込
       ↓
  init-guard ──── 必須ファイル Read 強制
       ↓
  subtask 選択
       ↓
┌─────────────────────────────────────┐
│ PreToolUse ガード群（並列発火）      │
│  ├─ playbook-guard（playbook 存在） │
│  ├─ check-main-branch（main 禁止）  │
│  ├─ check-protected-edit（HARD_BLOCK）│
│  ├─ consent-guard（危険操作同意）    │
│  ├─ pre-bash-check（Bash 制御）     │
│  └─ executor-guard（executor 制御）  │
└─────────────────────────────────────┘
       ↓
  Edit/Write/Bash 実行
       ↓
  subtask-guard ─ 3観点検証
       ↓
  scope-guard ─── done_criteria 変更検出
       ↓
  lint-checker / test-runner
       ↓
  validations 記入完了 → 検証動線へ
```

### 3.3 検証動線（6 コンポーネント）

```
  Phase 完了宣言
       ↓
    /crit ─────── 検証起点
       ↓
   critic ─────── done_criteria 検証
       ↓
 critic-guard ─── critic PASS 必須
       ↓
    /test, /lint, reviewer（オプション）
       ↓
  PASS/FAIL 判定 → 完了動線へ
```

### 3.4 完了動線（8 コンポーネント）

```
  全 Phase 完了
       ↓
archive-playbook ─ アーカイブ提案
       ↓
 cleanup-hook ──── tmp/ クリーンアップ
       ↓
create-pr-hook ─── PR 作成
       ↓
  post-loop ────── 完了後処理
       ↓
      pm ────────── 次タスク導出
       ↓
    state / context-management / focus
       ↓
次の計画動線へ or セッション終了
```

### 3.5 共通基盤（6 コンポーネント）

```
session-start → [各動線] → pre-compact → stop-summary → session-end
                    ↑
            log-subagent, consent-process（随時）
```

### 3.6 横断的整合性（3 コンポーネント）

```
check-coherence ─ focus/playbook/branch の整合性
depends-check ─── playbook 間の依存関係
lint-check ────── コード変更時の静的解析
```

---

## 4. Layer 分類の基準

### 不可欠性フレームワーク

| 基準 | Core | Quality | Extension |
|------|------|---------|-----------|
| これがないと？ | 破綻 | 品質低下 | 不便 |
| 代替手段 | なし | あるが危険 | あり |
| Core Contract | 明示的に必須 | 推奨 | 言及なし |
| 変更ポリシー | 凍結 | 保護（レビュー必須） | 柔軟 |

### 各動線の評価

| 動線 | ないと？ | 代替？ | Core Contract | 判定 |
|------|---------|--------|---------------|------|
| 計画動線 | playbook なし→破綻 | なし | pm 必須 | **Core** |
| 検証動線 | 報酬詐欺可能→破綻 | なし | critic 必須 | **Core** |
| 実行動線 | ガードなし→品質低下 | 動くが危険 | playbook-guard 必須 | **Quality** |
| 完了動線 | 手動で代替可 | あり | 言及なし | **Extension** |
| 共通基盤 | 状態把握困難 | 動く | 言及なし | **Extension** |
| 横断的整合性 | 整合性リスク | 動く | 言及なし | **Extension** |

---

## 5. Layer 配置候補

### Core Layer（12 コンポーネント）- 凍結

**計画動線（6）**:
- /task-start, pm, state, plan-management, prompt-guard, playbook-init

**検証動線（6）**:
- /crit, critic, reviewer, test, lint, critic-guard

### Quality Layer（11 コンポーネント）- 保護

**実行動線（11）**:
- init-guard, playbook-guard, subtask-guard, scope-guard
- check-protected-edit, pre-bash-check, consent-guard
- executor-guard, check-main-branch
- lint-checker, test-runner

### Extension Layer（17 コンポーネント）- 柔軟

**完了動線（8）**:
- rollback, state-rollback, focus
- archive-playbook, cleanup-hook, create-pr-hook
- post-loop, context-management

**共通基盤（6）**:
- session-start, session-end, pre-compact, stop-summary
- log-subagent, consent-process

**横断的整合性（3）**:
- check-coherence, depends-check, lint-check

### 統計

| Layer | コンポーネント数 |
|-------|-----------------|
| Core | 12 |
| Quality | 11 |
| Extension | 17 |
| **合計** | **40** |

---

## 6. 発見した動作不良

### subtask-guard.sh

**問題**: `STRICT_MODE` がデフォルト 0（WARN のみ）
```bash
STRICT_MODE="${STRICT:-0}"  # WARN で通過、BLOCK しない
```
**影響**: validations なしで subtask を完了できる

### critic-guard.sh

**問題**: `state.md` のみを対象とし、playbook の phase 完了をチェックしない
```bash
if [[ "$FILE_PATH" != *"state.md" ]]; then
    exit 0  # playbook はスルー
fi
```
**影響**: critic なしで phase を完了できる

### 修正方針（M105 で実装）

1. subtask-guard: デフォルトを STRICT=1 に変更、または playbook 編集時は常に BLOCK
2. critic-guard: playbook の `status: done` への変更もチェック対象に

---

## 7. M105 への引き継ぎ事項

### 実装タスク

1. **core-manifest.yaml v3 作成**: 動線ベースの Layer 構造に書き換え
2. **subtask-guard 修正**: デフォルト BLOCK 化
3. **critic-guard 修正**: playbook 対応
4. **check.md 維持**: 動線ベースの分類を正本として維持
5. **動作テスト設計**: 全 40 コンポーネントの動作確認スクリプト

### 依存関係

```
M104（本マイルストーン）
    ↓
M105（実装）
    ↓
動作テスト → 安定化
```

---

## 付録: リポジトリ概要

> **M148 で ARCHITECTURE.md から移行した情報**

### A. エントリーポイント

Claude Code がセッション開始時に読み込む順序:

```
1. CLAUDE.md          - 行動ルール（Frozen Constitution）
2. state.md           - 現在の状態（focus, playbook, goal）
3. plan/project.md    - プロジェクト計画（milestones）
4. playbook (if any)  - 現在の作業計画
5. docs/essential-documents.md - 動線単位の必須ドキュメント
```

### B. ディレクトリ構成

```
/
├── CLAUDE.md              # LLM の行動ルール（不変）
├── RUNBOOK.md             # 手順書（変更可能）
├── AGENTS.md              # コーディングルール
├── README.md              # プロジェクト説明
├── state.md               # 現在状態（SSOT）
│
├── .claude/               # Claude Code 拡張システム
│   ├── settings.json      # Hook 登録・権限設定
│   ├── mcp.json           # MCP サーバー設定
│   ├── hooks/             # Hook スクリプト
│   ├── agents/            # SubAgent 定義
│   ├── skills/            # Skill 定義
│   ├── commands/          # スラッシュコマンド
│   ├── schema/            # state.md スキーマ定義
│   ├── logs/              # 実行ログ
│   └── tests/             # done_criteria テスト
│
├── plan/                  # 計画管理
│   ├── project.md         # プロジェクト計画
│   ├── playbook-*.md      # 進行中 playbook
│   ├── archive/           # 完了済み playbook
│   └── template/          # playbook テンプレート
│
├── docs/                  # ドキュメント
│   ├── essential-documents.md  # 動線単位の必須ドキュメント（自動生成）
│   ├── extension-system.md
│   ├── hook-responsibilities.md
│   ├── folder-management.md
│   └── ... (他ドキュメント)
│
├── governance/            # ガバナンス
│   ├── core-manifest.yaml # コンポーネント正本
│   └── context-manifest.yaml
│
├── setup/                 # セットアップ関連
├── tmp/                   # テンポラリ（.gitignore）
└── .archive/              # アーカイブ済みファイル
```

### C. コンポーネント統計

| カテゴリ | 数 |
|----------|-----|
| Core Layer | 12 |
| Quality Layer | 10 |
| Extension Layer | 16 |
| **合計** | **38** |

> 詳細は `governance/core-manifest.yaml` を参照

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | M148: ARCHITECTURE.md から付録セクションを移行 |
| 2025-12-20 | M104 成果物として作成。黄金動線ベースの Layer 設計。 |
