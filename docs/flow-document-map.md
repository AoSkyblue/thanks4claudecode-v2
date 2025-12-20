# Flow Document Map

> **ドキュメントを4つの動線にマッピング**
>
> 各動線に必要なドキュメントを明確化し、参照効率を向上させる。
>
> 作成日: 2025-12-21
> マイルストーン: M117

---

## 動線概要

```
黄金動線:
  /task-start --> pm --> playbook --> work --> /crit --> critic --> done

4つの動線:
  1. 計画動線: 要求 --> [理解確認] --> pm --> playbook --> state.md
  2. 実行動線: playbook --> Edit --> Guard発火
  3. 検証動線: /crit --> critic --> PASS/FAIL
  4. 完了動線: phase完了 --> マージ --> アーカイブ --> state更新
```

---

## 1. 計画動線

> **要求 --> [理解確認] --> pm --> playbook --> state.md**

### 関連ドキュメント

| ファイル | 役割 | 参照タイミング |
|----------|------|----------------|
| **ai-orchestration.md** | 役割ベース executor の設計 | playbook 作成時 |
| **playbook-schema-v2.md** | Playbook のフォーマット仕様 | playbook 作成時 |
| **criterion-validation-rules.md** | done_criteria の記述ルール | playbook 作成時 |

### 関連コンポーネント

| 種別 | 名前 | 役割 |
|------|------|------|
| Command | /task-start | タスク開始コマンド |
| Command | /playbook-init | Playbook 初期化コマンド |
| SubAgent | pm.md | Playbook 作成・管理 |
| Skill | state | state.md 管理 |
| Skill | plan-management | 計画管理 |
| Hook | prompt-guard.sh | タスク要求パターン検出 |

---

## 2. 実行動線

> **playbook --> Edit --> Guard発火**

### 関連ドキュメント

| ファイル | 役割 | 参照タイミング |
|----------|------|----------------|
| **hook-exit-code-contract.md** | Hook の exit code 契約 | Hook 開発・デバッグ時 |
| **hook-responsibilities.md** | 各 Hook の責任定義 | Hook 設計・修正時 |
| **core-contract.md** | 核心契約（admin 含む） | Guard 発火時 |

### 関連コンポーネント

| 種別 | 名前 | 役割 |
|------|------|------|
| Hook | init-guard.sh | 初期化チェック |
| Hook | playbook-guard.sh | Playbook 存在チェック |
| Hook | subtask-guard.sh | Subtask 完了チェック |
| Hook | scope-guard.sh | スコープチェック |
| Hook | check-protected-edit.sh | 保護ファイルチェック |
| Hook | pre-bash-check.sh | 危険コマンドチェック |
| Hook | consent-guard.sh | 理解確認チェック |
| Hook | executor-guard.sh | Executor チェック |
| Hook | check-main-branch.sh | Main ブランチチェック |
| Hook | lint-checker.sh | Lint チェック |
| Hook | test-runner.sh | テスト実行 |

---

## 3. 検証動線

> **/crit --> critic --> PASS/FAIL**

### 関連ドキュメント

| ファイル | 役割 | 参照タイミング |
|----------|------|----------------|
| **verification-criteria.md** | PASS/FAIL 判定基準 | 検証実行時 |
| **criterion-validation-rules.md** | Criterion の検証ルール | 検証設計時 |

### 関連コンポーネント

| 種別 | 名前 | 役割 |
|------|------|------|
| Command | /crit | Critic 呼び出し |
| Command | /test | テスト実行 |
| Command | /lint | Lint 実行 |
| SubAgent | critic.md | 完了判定 |
| SubAgent | reviewer.md | Playbook レビュー |
| Hook | critic-guard.sh | Critic 呼び出しチェック |

---

## 4. 完了動線

> **phase完了 --> マージ --> アーカイブ --> state更新**

### 関連ドキュメント

| ファイル | 役割 | 参照タイミング |
|----------|------|----------------|
| **folder-management.md** | フォルダ管理・アーカイブルール | Playbook 完了時 |
| **freeze-then-delete.md** | 安全な削除プロセス | ファイル削除時 |
| **git-operations.md** | Git 操作リファレンス | マージ・ブランチ削除時 |

### 関連コンポーネント

| 種別 | 名前 | 役割 |
|------|------|------|
| Command | /rollback | ロールバック |
| Command | /state-rollback | State ロールバック |
| Command | /focus | Focus 切り替え |
| Hook | archive-playbook.sh | Playbook アーカイブ |
| Hook | cleanup-hook.sh | tmp/ クリーンアップ |
| Hook | create-pr-hook.sh | PR 作成 |
| Skill | post-loop | 完了処理 |
| Skill | context-management | コンテキスト管理 |

---

## 5. 共通基盤

> **全動線で共通して参照されるドキュメント**

### 関連ドキュメント

| ファイル | 役割 | 参照タイミング |
|----------|------|----------------|
| **ARCHITECTURE.md** | アーキテクチャ全体像 | 設計・理解時 |
| **extension-system.md** | Claude Code 拡張システム | Hook/SubAgent 開発時 |
| **layer-architecture-design.md** | Layer アーキテクチャ設計 | 動線設計時 |
| **core-functions.md** | コア機能定義 | 機能確認時 |
| **session-management.md** | セッション管理 | セッション操作時 |
| **repository-map.yaml** | ファイルマッピング | 自己認識時 |

### 関連コンポーネント

| 種別 | 名前 | 役割 |
|------|------|------|
| Hook | session-start.sh | セッション開始 |
| Hook | session-end.sh | セッション終了 |
| Hook | pre-compact.sh | Compact 前処理 |
| Hook | stop-summary.sh | 停止サマリー |
| Hook | log-subagent.sh | SubAgent ログ |
| Skill | consent-process | 同意プロセス |
| Hook | check-coherence.sh | 整合性チェック |
| Hook | depends-check.sh | 依存チェック |
| Hook | lint-check.sh | Lint チェック |

---

## クイックリファレンス

### 動線別ドキュメント早見表

```
計画動線:
  ├── ai-orchestration.md (executor 設計)
  ├── playbook-schema-v2.md (フォーマット)
  └── criterion-validation-rules.md (記述ルール)

実行動線:
  ├── hook-exit-code-contract.md (Hook 契約)
  ├── hook-responsibilities.md (責任定義)
  └── core-contract.md (核心契約)

検証動線:
  ├── verification-criteria.md (判定基準)
  └── criterion-validation-rules.md (検証ルール)

完了動線:
  ├── folder-management.md (フォルダ管理)
  ├── freeze-then-delete.md (削除プロセス)
  └── git-operations.md (Git 操作)

共通基盤:
  ├── ARCHITECTURE.md (全体像)
  ├── extension-system.md (拡張システム)
  ├── layer-architecture-design.md (Layer 設計)
  ├── core-functions.md (コア機能)
  ├── session-management.md (セッション)
  └── repository-map.yaml (マッピング)
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成。4動線 + 共通基盤にドキュメントをマッピング。 |
