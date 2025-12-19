# thanks4claudecode

> **Claude Code の自律性を構造的に制御するフレームワーク**

**GitHub**: https://github.com/M2AI-jp/thanks4claudecode-fresh

---

## このリポジトリが保証すること

1. **Playbook Gate**: playbook なしでの Edit/Write/Bash 変更系をブロック
2. **HARD_BLOCK**: 保護ファイル（CLAUDE.md 等）への編集を拒否
3. **Deadlock 回避**: playbook 完了後のコミット操作は許可

## 保証しないこと

- LLM の出力品質（それは Claude 自身の能力に依存）
- SubAgent/Skill の動作保証（設定であり成果保証ではない）

---

## クイックスタート

```bash
# リポジトリをクローン
git clone https://github.com/M2AI-jp/thanks4claudecode-fresh.git
cd thanks4claudecode-fresh

# Claude Code で開く
claude

# 公開前チェック（3コマンド）
bash scripts/behavior-test.sh      # 挙動テスト
bash scripts/find-unused.sh        # 未使用ファイル検出
bash scripts/e2e-contract-test.sh  # 契約テスト
```

### 基本的な使い方

1. **タスクを依頼する** → pm SubAgent が自動で playbook（計画書）を作成
2. **playbook に従って作業** → Hook が構造的に制御
3. **完了時に critic が検証** → 報酬詐欺を防止

---

## 主要機能

| 機能 | 説明 |
|------|------|
| 計画駆動開発 | playbook なしでの Edit/Write をブロック |
| 構造的強制 | Hook で LLM の意思に依存しない制御 |
| コンテキスト外部化 | state.md で状態を永続化 |

---

## アーキテクチャ

```
CLAUDE.md
  ↓ 思考制御
Hook（登録済のみ動作）
  ↓ 構造的強制
state.md ← Single Source of Truth
```

### Contract System

全ての契約判定を `scripts/contract.sh` に集約:

```bash
contract_check_edit()   # Edit/Write の判定
contract_check_bash()   # Bash コマンドの判定
is_hard_block()         # 絶対保護ファイル判定
is_compound_command()   # 複合コマンド検出
```

### Core Contract（admin でも回避不可）

- **Golden Path**: タスク依頼 → pm 必須
- **Playbook Gate**: playbook=null で Edit/Write/Bash 変更系をブロック
- **HARD_BLOCK**: CLAUDE.md 等の保護ファイルは編集不可

### コンポーネント統計

<!-- STATS_START -->
| 項目 | 数 |
|------|-----|
| Hook | 22 |
| SubAgent | 3 |
| Skill | 7 |
| Command | 8 |
<!-- STATS_END -->

> **自動生成**: `bash scripts/generate-readme-stats.sh --update` で最新化

### コンポーネント分類

| 分類 | 説明 |
|------|------|
| **Core** | 黄金動線に必須。削除不可 |
| **Optional** | 便利だが必須ではない |
| **Experimental** | 試験的または廃止候補 |

> 詳細: `governance/core-manifest.yaml`

---

## ファイル構造

```
.
├── CLAUDE.md               # ルールブック（凍結）
├── state.md                # 現在の状態
├── governance/
│   └── core-manifest.yaml  # コア機能の正本
├── scripts/
│   ├── contract.sh         # 契約判定中核
│   ├── behavior-test.sh    # 挙動テスト
│   └── find-unused.sh      # 未使用検出
├── .claude/
│   ├── hooks/              # Hook（登録済のみ動作）
│   ├── agents/             # SubAgent
│   ├── skills/             # Skill
│   └── settings.json       # Hook 登録
└── plan/
    ├── project.md          # プロジェクト計画
    └── archive/            # 完了した playbook
```

---

## テスト

```bash
# 挙動テスト（Playbook Gate, HARD_BLOCK, Deadlock 回避）
bash scripts/behavior-test.sh

# 契約テスト（シナリオ別）
bash scripts/e2e-contract-test.sh all

# 未使用ファイル検出
bash scripts/find-unused.sh
```

---

## Core SubAgent

| SubAgent | 役割 |
|----------|------|
| pm | playbook 作成・進捗管理 |
| critic | done_when 達成検証 |

> その他の SubAgent は `governance/core-manifest.yaml` 参照

---

## 凍結ポリシー

```yaml
policy:
  no_new_components: true
  allow_changes:
    - bugfix
    - deletion
    - test_improvement
```

> 新しい Hook/SubAgent/Skill の追加は禁止。詳細は `governance/core-manifest.yaml`

---

## 連絡先

[M2AI-jp](https://github.com/M2AI-jp) が管理。Issue/PR 歓迎。
