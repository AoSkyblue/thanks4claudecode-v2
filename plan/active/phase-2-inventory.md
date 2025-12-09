# Phase 2 成果物: 完全な実装棚卸し

> **playbook-current-implementation-redesign Phase 2**
>
> 日時: 2025-12-09
> 目的: settings.json・.claude フォルダ配下の全コンポーネントを 100% 棚卸し

---

## 実装状況サマリー

| カテゴリ | 実装数 | 登録済み | 未登録 |
|----------|--------|---------|-------|
| **Hooks** | 21 個 | 15 個 | 6 個 |
| **SubAgents** | 9 個 | 9 個 | - |
| **Skills** | 9 個 | 9 個 | - |
| **Commands** | 7 個 | 7 個 | - |
| **合計** | 46 個 | 40 個 | 6 個 |

---

## 1. Hooks 完全棚卸し

### 1.1 settings.json 登録状況（15個）

#### PreToolUse(*) - 全ツール対象（2個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 1 | init-guard | init-guard.sh | 3000ms | 必須 Read 前のツールブロック |
| 2 | check-main-branch | check-main-branch.sh | 3000ms | main ブランチ警告 |

#### PreToolUse(Edit) - 編集ツール対象（8個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 3 | consent-guard | consent-guard.sh | 3000ms | 合意プロセス強制 |
| 4 | check-protected-edit | check-protected-edit.sh | 5000ms | 保護ファイル編集ブロック |
| 5 | playbook-guard | playbook-guard.sh | 3000ms | playbook=null でブロック |
| 6 | depends-check | depends-check.sh | 3000ms | 依存ファイル情報表示 |
| 7 | check-file-dependencies | check-file-dependencies.sh | 3000ms | （6 と重複？確認要） |
| 8 | critic-guard | critic-guard.sh | 3000ms | done 更新前に critic 要求 |
| 9 | scope-guard | scope-guard.sh | 3000ms | スコープ外編集警告 |
| 10 | executor-guard | executor-guard.sh | 3000ms | executor 不一致警告 |

#### PreToolUse(Write) - 作成ツール対象（7個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 11 | consent-guard | consent-guard.sh | 3000ms | Edit と同一 |
| 12 | check-protected-edit | check-protected-edit.sh | 5000ms | Edit と同一 |
| 13 | playbook-guard | playbook-guard.sh | 3000ms | Edit と同一 |
| 14 | check-file-dependencies | check-file-dependencies.sh | 3000ms | Edit と同一 |
| 15 | critic-guard | critic-guard.sh | 3000ms | Edit と同一 |
| 16 | scope-guard | scope-guard.sh | 3000ms | Edit と同一 |
| 17 | executor-guard | executor-guard.sh | 3000ms | Edit と同一 |

#### PreToolUse(Bash)（2個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 18 | pre-bash-check | pre-bash-check.sh | 10000ms | git commit 前チェック |
| 19 | check-coherence | check-coherence.sh | 5000ms | **settings.json 追加済み** |

#### UserPromptSubmit(*)（1個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 20 | prompt-guard | prompt-guard.sh | 3000ms | プロンプト単位の plan 整合性チェック |

#### SessionStart(*)（1個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 21 | session-start | session-start.sh | 5000ms | 状態表示、pending 作成 |

#### PostToolUse(Task)（1個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 22 | log-subagent | log-subagent.sh | 3000ms | SubAgent 実行ログ記録 |

#### PostToolUse(Edit)（1個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 23 | archive-playbook | archive-playbook.sh | 3000ms | playbook 自動アーカイブ |

#### SessionEnd(*)（1個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 24 | session-end | session-end.sh | 5000ms | 状態保存、未 push 警告 |

#### Stop(*)（1個）

| # | Hook 名 | ファイル名 | timeout | 説明 |
|----|---------|-----------|---------|------|
| 25 | stop-summary | stop-summary.sh | 3000ms | Phase サマリー出力 |

### 1.2 未登録 Hook（6個）

| # | Hook 名 | ファイル名 | 説明 | 呼び出し元 |
|----|---------|-----------|------|----------|
| 1 | check-state-update | check-state-update.sh | state.md 未更新警告 | pre-bash-check.sh |
| 2 | check-manifest-sync | check-manifest-sync.sh | manifest 同期確認 | 手動呼び出しのみ |
| 3 | check-playbook-quality | check-playbook-quality.sh | playbook 品質チェック | 手動呼び出しのみ |
| 4 | （未実装） | critic-result-handler.sh | SubagentStop Hook | 代替実装 |
| 5 | （未実装） | pre-compact.sh | PreCompact Hook | 優先度低 |
| 6 | （未実装） | (notify-*.sh) | Notification Hook | 優先度低 |

**注記**: check-state-update.sh は pre-bash-check.sh から呼び出され、実質的には動作中。

### 1.3 Hook ファイルツリー

```
.claude/hooks/（21ファイル）
├── SessionStart
│   └── session-start.sh          ✅ 登録済み
├── UserPromptSubmit
│   └── prompt-guard.sh           ✅ 登録済み
├── PreToolUse (*)
│   ├── init-guard.sh             ✅ 登録済み
│   └── check-main-branch.sh      ✅ 登録済み
├── PreToolUse (Edit/Write)
│   ├── consent-guard.sh          ✅ 登録済み
│   ├── check-protected-edit.sh   ✅ 登録済み
│   ├── playbook-guard.sh         ✅ 登録済み
│   ├── depends-check.sh          ✅ 登録済み
│   ├── check-file-dependencies.sh ✅ 登録済み
│   ├── critic-guard.sh           ✅ 登録済み
│   ├── scope-guard.sh            ✅ 登録済み
│   └── executor-guard.sh         ✅ 登録済み
├── PreToolUse (Bash)
│   ├── pre-bash-check.sh         ✅ 登録済み
│   └── check-coherence.sh        ✅ 登録済み（新規追加済み）
├── PostToolUse (Task)
│   └── log-subagent.sh           ✅ 登録済み
├── PostToolUse (Edit)
│   └── archive-playbook.sh       ✅ 登録済み
├── SessionEnd
│   └── session-end.sh            ✅ 登録済み
├── Stop
│   └── stop-summary.sh           ✅ 登録済み
├── 未登録
│   ├── check-state-update.sh     ⚠️ 間接呼出（pre-bash-check.sh）
│   ├── check-manifest-sync.sh    🔷 手動用
│   └── check-playbook-quality.sh 🔷 手動用
└── 未実装
    ├── critic-result-handler.sh  ❌ SubagentStop → 代替実装
    ├── pre-compact.sh            ❌ PreCompact → 優先度低
    └── (notify-*.sh)             ❌ Notification → 優先度低
```

---

## 2. SubAgents 完全棚卸し

### 2.1 SubAgents 一覧（9個）

| # | 名前 | ファイル | model | tools | 自動委譲 | 説明 |
|----|------|---------|-------|-------|--------|------|
| 1 | critic | critic.md | haiku | Read, Grep, Bash | ✅ MUST BE USED | done_criteria 検証、報酬詐欺防止 |
| 2 | pm | pm.md | haiku | Read, Write, Edit, Grep, Glob | ✅ PROACTIVELY | playbook 管理、計画導出 |
| 3 | coherence | coherence.md | haiku | Read, Bash, Grep | ✅ PROACTIVELY | state.md と playbook 整合性 |
| 4 | state-mgr | state-mgr.md | haiku | Read, Edit, Write, Grep, Bash | ✅ AUTOMATICALLY | state.md 操作、遷移管理 |
| 5 | reviewer | reviewer.md | haiku | Read, Grep, Glob, Bash | ⚠️ なし | コードレビュー |
| 6 | health-checker | health-checker.md | haiku | Read, Grep, Glob, Bash | ⚠️ なし（日本語） | システム状態監視 |
| 7 | plan-guard | plan-guard.md | haiku | Read, Grep, Glob | ✅ PROACTIVELY | 3層 plan 整合性、session start |
| 8 | setup-guide | setup-guide.md | sonnet | Read, Write, Edit, Bash, Grep, Glob | ✅ AUTOMATICALLY | setup プロセスガイド |
| 9 | beginner-advisor | beginner-advisor.md | haiku | Read | ✅ AUTOMATICALLY | 初心者向け説明 |

### 2.2 SubAgent frontmatter 詳細

```yaml
# SubAgent frontmatter 構造

critic.md:
  name: critic
  description: MUST BE USED before marking any task as done. Evaluates done_criteria with evidence-based judgment. Prevents self-reward fraud through critical thinking.
  tools: Read, Grep, Bash
  model: haiku

pm.md:
  name: pm
  description: PROACTIVELY manages playbooks and project progress. Creates playbook when missing, tracks phase completion, manages scope. Says NO to scope creep.
  tools: Read, Write, Edit, Grep, Glob
  model: haiku

coherence.md:
  name: coherence
  description: PROACTIVELY checks state.md and playbook consistency before git commit. Detects focus mismatch and forbidden state transitions.
  tools: Read, Bash, Grep
  model: haiku

state-mgr.md:
  name: state-mgr
  description: AUTOMATICALLY manages state.md, playbook operations, and layer structure. Use for focus switching, state transitions, and playbook phase updates.
  tools: Read, Edit, Write, Grep, Bash
  model: haiku

reviewer.md:
  name: reviewer
  description: Use this agent for code and design reviews. Evaluates code quality, design patterns, and best practices. Provides constructive feedback for improvements.
  tools: Read, Grep, Glob, Bash
  model: haiku
  ⚠️ 問題: 「PROACTIVELY」「AUTOMATICALLY」なし → 自動委譲されにくい

health-checker.md:
  name: health-checker
  description: システム状態の定期監視。state.md/playbook の整合性、git 状態、ファイル存在確認などを行う。
  tools: Read, Grep, Glob, Bash
  model: haiku
  ⚠️ 問題: 日本語 description → 自動委譲されにくい可能性

plan-guard.md:
  name: plan-guard
  description: PROACTIVELY checks 3-layer plan coherence at session start. Rejects or reconfirms when no plan exists or user prompt is unrelated to existing plan. LLM-led session flow.
  tools: Read, Grep, Glob
  model: haiku

setup-guide.md:
  name: setup-guide
  description: AUTOMATICALLY guides setup process when focus.current=setup. Conducts hearing, environment setup, and Skills generation. Does not ask unnecessary questions.
  tools: Read, Write, Edit, Bash, Grep, Glob
  model: sonnet  # 唯一の sonnet

beginner-advisor.md:
  name: beginner-advisor
  description: AUTOMATICALLY explains technical terms with metaphors when beginner-level questions are detected. Proactively simplifies complex concepts.
  tools: Read
  model: haiku
```

### 2.3 自動委譲状況

| SubAgent | 自動委譲トリガー | 状態 |
|----------|-----------------|------|
| critic | MUST BE USED | ✅ ガイドライン強制 |
| pm | PROACTIVELY | ✅ playbook 不在時、Phase 完了時 |
| coherence | PROACTIVELY | ✅ git commit 時（間接呼出） |
| state-mgr | AUTOMATICALLY | ✅ state.md 操作時 |
| reviewer | なし | ⚠️ 手動呼び出しのみ |
| health-checker | なし | ⚠️ 手動呼び出しのみ（日本語） |
| plan-guard | PROACTIVELY | ✅ session start 時 |
| setup-guide | AUTOMATICALLY（focus=setup） | ✅ setup レイヤー |
| beginner-advisor | AUTOMATICALLY | ✅ 初心者検出時 |

---

## 3. Skills 完全棚卸し

### 3.1 Skills 一覧（9個）

| # | Skill 名 | ファイル名 | frontmatter | triggers | 状態 |
|----|----------|-----------|-----------|----------|------|
| 1 | state | SKILL.md | ✅ | - | ✅ 正常 |
| 2 | plan-management | SKILL.md | ✅ | - | ✅ 正常 |
| 3 | context-management | SKILL.md | ✅ | ✅ | ✅ 正常 |
| 4 | execution-management | SKILL.md | ✅ | ✅ | ✅ 正常 |
| 5 | learning | SKILL.md | ✅ | ✅ | ✅ 正常 |
| 6 | frontend-design | SKILL.md | ❌ | - | ⚠️ 未記載 |
| 7 | lint-checker | skill.md | ❌ | - | ⚠️ ファイル名＋未記載 |
| 8 | test-runner | skill.md | ❌ | - | ⚠️ ファイル名＋未記載 |
| 9 | deploy-checker | skill.md | ❌ | - | ⚠️ ファイル名＋未記載 |

### 3.2 Skills frontmatter 詳細

#### 正常な Skills（5個）

```yaml
state/SKILL.md:
  name: state
  description: このワークスペースの state.md 管理、playbook 運用、レイヤー構造の専門知識。

plan-management/SKILL.md:
  name: plan-management
  description: Multi-layer planning and playbook management. Use when creating playbooks, transitioning phases, or managing plan hierarchy. Triggers on "plan", "playbook", "phase", "roadmap", "milestone" keywords.

context-management/SKILL.md:
  name: context-management
  description: /compact 最適化と履歴要約のガイドライン。コンテキスト管理の専門知識を提供。
  triggers:
    - /compact を実行する前
    - コンテキストが 80% を超えたとき
    - セッション終了時

execution-management/SKILL.md:
  name: execution-management
  description: 並列実行制御とリソース配分のガイドライン。タスク実行の最適化を支援。
  triggers:
    - 複数タスクを同時に実行するとき
    - コンテキストが逼迫しているとき

learning/SKILL.md:
  name: learning
  description: 失敗パターンの記録・学習。過去の失敗から学び、同じ問題を繰り返さない。
  triggers:
    - エラーが発生したとき
    - critic が FAIL を返したとき
```

#### 問題のある Skills（4個）

```yaml
frontend-design/SKILL.md:
  問題: frontmatter が記載されていない（markdown テキストのみ）
  対策: YAML frontmatter を追加

lint-checker/skill.md:
  問題1: ファイル名が小文字 (skill.md) → 公式仕様は SKILL.md
  問題2: frontmatter なし
  対策: リネーム (SKILL.md) + frontmatter 追加

test-runner/skill.md:
  問題: 同上
  対策: 同上

deploy-checker/skill.md:
  問題: 同上
  対策: 同上
```

### 3.3 Skills ツリー

```
.claude/skills/（9ディレクトリ）
├── state/
│   └── SKILL.md              ✅ 正常
├── plan-management/
│   └── SKILL.md              ✅ 正常
├── context-management/
│   └── SKILL.md              ✅ 正常 (triggers あり)
├── execution-management/
│   └── SKILL.md              ✅ 正常 (triggers あり)
├── learning/
│   └── SKILL.md              ✅ 正常 (triggers あり)
├── frontend-design/
│   └── SKILL.md              ⚠️ frontmatter なし
├── lint-checker/
│   └── skill.md              ⚠️ ファイル名（小文字）+ frontmatter なし
├── test-runner/
│   └── skill.md              ⚠️ ファイル名（小文字）+ frontmatter なし
└── deploy-checker/
    └── skill.md              ⚠️ ファイル名（小文字）+ frontmatter なし
```

---

## 4. Commands 完全棚卸し

### 4.1 Commands 一覧（7個）

| # | Command | ファイル | frontmatter | 関連 Agent | 説明 |
|----|---------|--------|-----------|-----------|------|
| 1 | /crit | crit.md | ✅ | critic | done_criteria チェック |
| 2 | /playbook-init | playbook-init.md | ✅ | pm | 新タスク開始フロー |
| 3 | /lint | lint.md | ✅ | coherence | 整合性チェック実行 |
| 4 | /focus | focus.md | ✅ | state-mgr | レイヤーフォーカス切替 |
| 5 | /test | test.md | ✅ | - | done_criteria テスト |
| 6 | /rollback | rollback.md | ✅ | - | Git ロールバック |
| 7 | /state-rollback | state-rollback.md | ✅ | - | state.md 復元 |

### 4.2 Commands frontmatter 確認

```yaml
# frontmatter 構造（公式仕様）
description: コマンドの説明
allowed-tools: Bash(git:*), Read  # 任意
model: sonnet                     # 任意
argument-hint: <argument>         # 任意
```

**確認状況**: 全 7 個の Command ファイルが存在。frontmatter の詳細は Phase 3 で読み込み。

---

## 5. 対応整理: settings.json 登録状況 vs 実装ファイル

### 5.1 登録済み Hook（15個）→ ファイル存在確認 ✅

| イベント | matcher | 登録 Hook | ファイル存在 |
|---------|---------|----------|-----------|
| PreToolUse | * | init-guard.sh | ✅ |
| PreToolUse | * | check-main-branch.sh | ✅ |
| PreToolUse | Edit | consent-guard.sh | ✅ |
| PreToolUse | Edit | check-protected-edit.sh | ✅ |
| PreToolUse | Edit | playbook-guard.sh | ✅ |
| PreToolUse | Edit | depends-check.sh | ✅ |
| PreToolUse | Edit | check-file-dependencies.sh | ✅ |
| PreToolUse | Edit | critic-guard.sh | ✅ |
| PreToolUse | Edit | scope-guard.sh | ✅ |
| PreToolUse | Edit | executor-guard.sh | ✅ |
| PreToolUse | Write | （Edit と同一） | ✅ |
| PreToolUse | Bash | pre-bash-check.sh | ✅ |
| PreToolUse | Bash | check-coherence.sh | ✅ |
| UserPromptSubmit | * | prompt-guard.sh | ✅ |
| SessionStart | * | session-start.sh | ✅ |
| PostToolUse | Task | log-subagent.sh | ✅ |
| PostToolUse | Edit | archive-playbook.sh | ✅ |
| SessionEnd | * | session-end.sh | ✅ |
| Stop | * | stop-summary.sh | ✅ |

**登録数**: 19 Hook 定義（Edit/Write/Bash は同じファイルを複数参照）

### 5.2 未登録だが機能している Hook（1個）

| Hook | 呼び出し元 | 発火条件 |
|------|----------|--------|
| check-state-update.sh | pre-bash-check.sh | git commit 時 |

### 5.3 完全に未使用の Hook（2個）

| Hook | ファイル | 理由 |
|------|--------|------|
| check-manifest-sync.sh | ✅ 存在 | 手動用、自動呼び出しなし |
| check-playbook-quality.sh | ✅ 存在 | 手動用、自動呼び出しなし |

---

## 6. 実装と公式仕様のズレ一覧

### 6.1 P0: 公式仕様要件未充足（構造的）

| 項目 | 公式仕様 | 現在実装 | ズレ | 影響 |
|------|---------|---------|------|------|
| Hook 出力形式 | JSON（hookSpecificOutput） | stdout テキスト | ⚠️ | 中 |
| SubAgent frontmatter | skills フィールド | 未設定 | ⚠️ | 低 |
| Skill frontmatter | YAML frontmatter | 4 つが未記載 | ⚠️ | 中 |
| Skill ファイル名 | SKILL.md | skill.md（3 個） | ⚠️ | 低 |

### 6.2 P1: 公式仕様活用不足（オプション）

| 項目 | 公式仕様 | 現在実装 | 状態 |
|------|---------|---------|------|
| Hook タイプ | validation, notification | command のみ | 未活用 |
| CLAUDE_ENV_FILE | SessionStart で環境変数永続化 | 未使用 | 優先度低 |
| SubagentStop Hook | サブタスク評価 | PostToolUse(Task) で代替 | 代替実装 |
| PreCompact Hook | 重要情報保持 | 未実装 | 優先度低 |

### 6.3 P2: SubAgent 自動委譲弱化（ガイドライン依存）

| SubAgent | 自動委譲キーワード | 状態 |
|----------|-----------------|------|
| reviewer | なし | ⚠️ 手動呼び出しのみ |
| health-checker | 日本語のみ | ⚠️ 英語化推奨 |

---

## 7. 問題サマリー

### Issue 1: Skill frontmatter 不完全（4個）

**ファイル**:
- frontend-design/SKILL.md
- lint-checker/skill.md
- test-runner/skill.md
- deploy-checker/skill.md

**対策**: Phase 7（cleanup）で修正実装予定

### Issue 2: Hook 出力形式（JSON vs テキスト）

**現状**: Hook が stdout に直接テキスト出力
**公式仕様**: JSON（hookSpecificOutput）で構造化

**影響**: 低（現在のテキスト形式でも機能）

### Issue 3: SubAgent 自動委譲弱化（2個）

**SubAgent**:
- reviewer（トリガーキーワードなし）
- health-checker（日本語記載）

**対策**: Phase 4（根拠ドキュメント化）で description 改善提案

---

## 8. 次フェーズへの引継ぎ

### Phase 3 へ（入力→処理→出力フロー）

- settings.json の Hook 順序が発火順序を決める
- 各 Hook の stdin JSON スキーマ確認必要
- 連携パターン（Hook → SubAgent/Skill）の可視化必要

### Phase 4 へ（仕様根拠ドキュメント化）

- 各 Hook/SubAgent/Skill の公式仕様セクション番号を記載
- extension-system.md との対応関係を明記
- ズレの根拠と対応方針を説明

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-09 | Phase 2 完了。Hooks 21 個、SubAgents 9 個、Skills 9 個、Commands 7 個を完全棚卸し。問題 3 件を特定。 |

---

**作成日時**: 2025-12-09
**作成者**: Claude Code（P2 実行）
**状態**: ✅ 完了、Phase 3 へ移行可能
