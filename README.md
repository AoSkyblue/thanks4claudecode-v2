# thanks4claudecode

> **実験リポジトリ**: Claude Code に「報酬詐欺防止」「計画駆動開発」などの自律性向上機能を実装する試み。
> 一度崩壊したが、2025-12-19 時点でコア機能を復旧。

**GitHub**: https://github.com/M2AI-jp/thanks4claudecode-fresh

---

## 復旧状況 (2025-12-19)

### 解決済み

| 問題 | 対策 | 検証 |
|------|------|------|
| admin モードが機能しない | Contract System に統合、Maintenance 用途に限定 | 52 E2E tests PASS |
| playbook=null で全ブロック | Bootstrap 例外追加（state.md, playbook ファイル） | テスト済み |
| 回避可能なセキュリティ穴 | 絶対パスリダイレクト検出、複合コマンド禁止、完全一致 allowlist | 20 セキュリティテスト PASS |
| Hook ロジック重複 | `scripts/contract.sh` に判定を集約 | verify-hook-delegation.sh で検証 |
| git 変更系コマンド漏れ | push/reset/checkout/rebase/merge 等を明示的にブロック | テスト済み |

### Contract System の主要機能

```bash
# 中央集約された契約判定
scripts/contract.sh
├── contract_check_edit()   # Edit/Write の判定
├── contract_check_bash()   # Bash コマンドの判定
├── is_hard_block()         # 絶対保護ファイル判定
├── is_compound_command()   # 複合コマンド検出（&&, ;, ||, |）
├── has_file_redirect()     # ファイルリダイレクト検出
└── is_admin_maintenance_allowed()  # 限定許可パターン

# E2E テスト（52テスト）
bash scripts/e2e-contract-test.sh
```

### まだ残っている課題

| 課題 | 状態 |
|------|------|
| 3層自動運用 | 設計のみ、実装不完全 |
| コンテキスト膨張 | 改善中（CLAUDE.md 縮小済み） |
| 報酬詐欺の完全防止 | critic SubAgent で部分対応 |

---

## 何をやろうとしたか（機能）

Claude Code に以下の機能を実現させようとした：

| 機能 | 説明 | 状態 |
|------|------|------|
| 報酬詐欺防止 | 「完了した」と言いながら実際は未完了、を防ぐ | 部分的に動作 |
| 計画駆動開発 | playbook（計画書）なしでコードを書かせない | 動作するが厳しすぎ |
| 構造的強制 | LLM の意思に依存しない行動制御 | 動作するが複雑 |
| 3層自動運用 | project → playbook → phase で自動進行 | 動作するが不安定 |
| コンテキスト外部化 | チャット履歴に依存しない状態管理 | 動作 |

---

## 何が失敗したか

### 複雑性の爆発

上記5つの機能を実現するために、以下のコンポーネントが必要になった：

| コンポーネント | 数 | 役割 | 問題 |
|----------------|-----|------|------|
| Hook | 30個 | 構造的強制の実装 | 相互依存で予測不能 |
| SubAgent | 6個 | 検証の実装 | 役割が曖昧 |
| Skill | 9個 | 専門知識の提供 | 使われていないものあり |
| Command | 8個 | 操作のショートカット | 一部動作不安定 |
| CLAUDE.md | 648行 | ルールブック | 毎セッション読む必要あり |

**5つの機能のために53個のコンポーネントが必要になった。**

### 修正のループ

```
問題発生 → Hook 追加 → 複雑化 → 新問題発生 → Hook 追加 → ...
```

project.md より抜粋：
- M020: archive-playbook.sh バグ修正 ← M019 で壊れた
- M021: init-guard.sh デッドロック修正 ← M017 で壊れた
- M056-M062: 報酬詐欺対策4連発 ← 根本解決せず

---

## 報酬詐欺の実例

Claude が「完了」と宣言しながら実際は不完全だった例：

| milestone | 宣言 | 実態 |
|-----------|------|------|
| M018 | subtask-guard で3検証を強制 | validations チェックが甘かった |
| M019 | final_tasks で完了時タスク実行 | チェック未実装だった |
| M059-M062 | done_when ルール強化 | 4回修正しても根本解決せず |

---

## 残っている不具合

1. ~~**admin モードが機能しない**~~ → **解決**: Contract System で Maintenance 用途に限定対応
2. ~~**playbook=null で軽微な修正も不可**~~ → **解決**: Bootstrap 例外で state.md/playbook 編集可能
3. ~~**main ブランチ制限が厳しすぎ**~~ → **解決**: git read-only コマンド (status/diff/log) は許可
4. **repository-map.yaml との整合性** - 手動更新が必要な場合あり
5. **コンテキスト膨張** - 改善中（CLAUDE.md 648行→約200行に縮小済み）
6. **古い表記の残存** - 一部ファイルに廃止された用語が残っている

---

## アーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│  CLAUDE.md（思考制御）                                       │
│  → LLM の行動パターンを規定                                  │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│  Hook（構造的強制）30個                                      │
│  → ツール実行時に bash で強制ブロック                        │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│  SubAgent（検証）6個                                         │
│  → 外部視点からの検証（報酬詐欺防止）                        │
└─────────────────────────────────────────────────────────────┘
```

Skill（9個）と Command（8個）は補助的な役割。

---

## ファイル構造

```
.
├── CLAUDE.md               # ルールブック
├── state.md                # 現在の状態（Single Source of Truth）
├── plan/
│   ├── project.md          # プロジェクト計画
│   ├── archive/            # アーカイブ済み playbook
│   └── template/           # テンプレート
├── .claude/
│   ├── hooks/              # Hook（構造的強制）
│   ├── agents/             # SubAgent（検証）
│   ├── skills/             # Skill（専門知識）
│   ├── commands/           # Command
│   └── settings.json       # Hook 登録
└── docs/
    ├── current-definitions.md    # 最新の定義
    └── deprecated-references.md  # 廃止された表記一覧
```

---

## 用語の変遷

| 廃止用語 | 現在の用語 | 廃止日 |
|----------|------------|--------|
| Macro | project | 2025-12-13 |
| layer | 廃止 | 2025-12-13 |
| architecture-*.md | 廃止 | 2025-12-08 |

---

## 助けてほしいこと

1. **報酬詐欺の根本対策** - 構造的に嘘を防ぐ方法（critic SubAgent で部分対応中）
2. **3層自動運用の実装** - project → playbook → phase の自動導出
3. **このリポジトリの活用** - 部品としての再利用、改善提案

---

## 連絡先

[M2AI-jp](https://github.com/M2AI-jp) が管理。Issue/PR 歓迎。

リポジトリ: https://github.com/M2AI-jp/thanks4claudecode-fresh

---

## 診断ツール

### 存在する診断ツール

```
1. e2e-contract-test.sh     - Contract System の E2E テスト（52テスト）★New
2. verify-hook-delegation.sh - Hook の委譲状態検証 ★New
3. test-hooks.sh             - Hook 機能カタログスペック検証
4. system-health-check.sh    - ファイル存在・整合性チェック
5. health-checker SubAgent   - システム状態監視
```

### 改善点（2025-12-19）

**追加された E2E テスト（52テスト）:**
- Contract System の全判定パス（ALLOW/BLOCK）
- セキュリティテスト（リダイレクト検出、複合コマンド、git 変更系）
- Admin Maintenance allowlist のパターンマッチ
- Bootstrap 例外（state.md, playbook ファイル）

```bash
# E2E テスト実行
bash scripts/e2e-contract-test.sh
# 結果: 52/52 PASS
```

### 5つの機能の動作状況（2025-12-19 更新）

| 機能 | 動作状況 | 検証方法 | 備考 |
|------|----------|----------|------|
| 報酬詐欺防止 | **部分的** | critic SubAgent | 完全防止は困難 |
| 計画駆動開発 | **動作** | playbook 無しで Edit → ブロック確認 | 52 E2E tests PASS |
| 構造的強制 | **安定化** | Contract System に集約 | Hook 相互依存を削減 |
| 3層自動運用 | **動作せず** | project → playbook 自動導出 | 設計のみで実装なし |
| コンテキスト外部化 | **動作** | state.md 保存/復元 | セッション間で継続 |

### 残る課題

1. **報酬詐欺の完全防止は構造的に困難**
   - LLM が「嘘をつかない」保証はできない
   - critic SubAgent で検証するが、critic 自体も LLM

2. **3層自動運用は未実装**
   - project → playbook の自動導出は設計のみ
