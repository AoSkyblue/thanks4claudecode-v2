# Phase 4 成果物: 仕様→実装の根拠ドキュメント

> **playbook-current-implementation-redesign Phase 4**
>
> 日時: 2025-12-09
> 目的: extension-system.md の各仕様項目に対して、実装が「どの部分」に対応するかを明記

---

## 1. Hooks 完全対応表（15個 + 未登録6個）

### 1.1 SessionStart Hook

| 項目 | 公式仕様 (extension-system.md) | 現在実装 |
|------|------------------------------|---------|
| **ファイル** | - | session-start.sh |
| **仕様セクション** | 1.1 SessionStart | ✅ 準拠 |
| **発火タイミング** | セッション開始/再開時 | ✅ SessionStart(*) |
| **入力 (stdin)** | `{ session_id, cwd }` | ✅ 使用せず（state.md 直接参照） |
| **環境変数** | CLAUDE_ENV_FILE | ⚠️ 未使用（永続化不要のため） |
| **出力** | stdout → コンテキスト追加 | ✅ 状態表示、必須 Read 指示 |
| **exit code** | 0 (成功) | ✅ 0 固定 |
| **実装根拠** | 1.7 連携パターン「SessionStart → [環境初期化]」 | pending + consent ファイル作成で後続 Hook を制御 |

### 1.2 UserPromptSubmit Hook

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **ファイル** | - | prompt-guard.sh |
| **仕様セクション** | 1.1 UserPromptSubmit | ✅ 準拠 |
| **発火タイミング** | ユーザープロンプト送信時 | ✅ UserPromptSubmit(*) |
| **入力 (stdin)** | `{ prompt, session_id }` | ✅ prompt を解析 |
| **出力** | stdout → コンテキスト追加 | ✅ スコープ外警告 |
| **exit code** | 0 (警告のみ) | ✅ 0 固定（ブロックなし） |
| **実装根拠** | 1.7「UserPromptSubmit → [入力検証]」 | project.md/playbook とプロンプトの整合性確認 |

### 1.3 PreToolUse(*) Hooks

#### 1.3.1 init-guard.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse, 6.1 ガードパターン | ✅ 準拠 |
| **発火タイミング** | ツール実行前 | ✅ PreToolUse(*) |
| **matcher** | `*` (全ツール) | ✅ settings.json L26-36 |
| **入力 (stdin)** | `{ tool_name, tool_input }` | ✅ jq で解析 |
| **exit code** | 0 (通過) / 2 (ブロック) | ✅ pending 時は exit 2 |
| **実装根拠** | 6.1「条件チェック → ブロック or 許可」 | 必須 Read 完了まで他ツールをブロック |

#### 1.3.2 check-main-branch.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse, 6.1 ガードパターン | ✅ 準拠 |
| **発火タイミング** | ツール実行前 | ✅ PreToolUse(*) |
| **matcher** | `*` (全ツール) | ✅ settings.json L34-36 |
| **条件** | focus=workspace && branch=main | ✅ exit 2 でブロック |
| **実装根拠** | project.md「1 playbook = 1 branch」ルール | main ブランチでの直接作業を防止 |

### 1.4 PreToolUse(Edit/Write) Hooks（8個）

#### 1.4.1 consent-guard.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse, 6.1 ガードパターン | ✅ 準拠 |
| **matcher** | Edit, Write | ✅ settings.json L44, L89 |
| **入力 (stdin)** | `{ tool_name }` | ✅ jq で解析 |
| **exit code** | 0 (合意済み) / 2 (未合意) | ✅ consent ファイル存在でブロック |
| **実装根拠** | project.md consent_protocol「誤解釈防止」 | [理解確認] 出力までブロック |

#### 1.4.2 check-protected-edit.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse, 6.1 ガードパターン | ✅ 準拠 |
| **matcher** | Edit, Write | ✅ settings.json L49, L94 |
| **参照ファイル** | .claude/protected-files.txt | ✅ BLOCK/WARN レベル判定 |
| **exit code** | 0 (許可) / 2 (BLOCK) | ✅ 保護レベルに応じて判定 |
| **実装根拠** | CLAUDE.md PROTECTED セクション | CLAUDE.md 等の保護 |

#### 1.4.3 playbook-guard.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse, 6.1 ガードパターン | ✅ 準拠 |
| **matcher** | Edit, Write | ✅ settings.json L54, L99 |
| **条件** | playbook=null | ✅ exit 2 でブロック |
| **exit code** | 0 (playbook あり) / 2 (なし) | ✅ pm 呼び出し指示を出力 |
| **実装根拠** | CLAUDE.md ACTION_GUARDS「アクションベース制御」 | Edit/Write 時のみ playbook 必須 |

#### 1.4.4 depends-check.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse | ✅ 準拠 |
| **matcher** | Edit | ✅ settings.json L59 |
| **処理** | playbook.depends_on をチェック | ✅ 未完了 Phase → 警告 |
| **exit code** | 0 (警告のみ) | ✅ 将来 exit 2 でブロック可能 |
| **実装根拠** | playbook 構造要件「depends_on」 | 依存関係違反の早期検出 |

#### 1.4.5 check-file-dependencies.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse | ✅ 準拠 |
| **matcher** | Edit, Write | ✅ settings.json L64, L104 |
| **処理** | ファイル依存関係を表示 | ✅ 情報提供のみ |
| **exit code** | 0 (常に通過) | ✅ ブロックなし |
| **実装根拠** | project.md hooks_subagents_claude_md_integration | 変更影響範囲の可視化 |

#### 1.4.6 critic-guard.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse, 6.1 ガードパターン | ✅ 準拠 |
| **matcher** | Edit | ✅ settings.json L69 |
| **条件** | state.md に "state: done" && self_complete=false | ✅ exit 2 でブロック |
| **exit code** | 0 (done 変更なし or critic 済) / 2 (未 critic) | ✅ critic 呼び出し指示 |
| **実装根拠** | project.md tdd_and_fraud_prevention「報酬詐欺防止」 | 証拠なき done を構造的に防止 |

#### 1.4.7 scope-guard.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse | ✅ 準拠 |
| **matcher** | Edit, Write | ✅ settings.json L74, L115 |
| **条件** | playbook.scope 外のファイル編集 | ✅ 警告（STRICT_MODE で exit 2） |
| **exit code** | 0 (警告のみ) / 2 (STRICT_MODE) | ✅ 環境変数で切り替え |
| **実装根拠** | project.md playbook_doubt_ability | スコープ外作業の抑制 |

#### 1.4.8 executor-guard.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse | ✅ 準拠 |
| **matcher** | Edit, Write | ✅ settings.json L79, L119 |
| **条件** | playbook.executor != claude_code | ✅ 警告のみ |
| **exit code** | 0 (警告のみ) | ✅ ブロックなし |
| **実装根拠** | project.md executor_design | 将来の複数 executor 対応準備 |

### 1.5 PreToolUse(Bash) Hooks（2個）

#### 1.5.1 pre-bash-check.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse | ✅ 準拠 |
| **matcher** | Bash | ✅ settings.json L129 |
| **処理** | git commit 時に check-state-update.sh 呼び出し | ✅ 間接的な Hook 連携 |
| **exit code** | 0 (常に通過) | ✅ check-state-update.sh の結果に依存 |
| **実装根拠** | project.md project_playbook_sync | git commit 前の状態確認 |

#### 1.5.2 check-coherence.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PreToolUse, 6.1 ガードパターン | ✅ 準拠 |
| **matcher** | Bash | ✅ settings.json L134 |
| **処理** | state.md と playbook の整合性を 5 項目でチェック | ✅ 不整合で exit 2 |
| **exit code** | 0 (整合) / 2 (不整合) | ✅ git commit をブロック |
| **実装根拠** | project.md project_playbook_sync「乖離検出」 | Macro-Medium-Micro 整合性保証 |

### 1.6 PostToolUse Hooks（2個）

#### 1.6.1 log-subagent.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PostToolUse, 6.2 検証パターン | ✅ 準拠 |
| **matcher** | Task | ✅ settings.json L167 |
| **入力 (stdin)** | `{ tool_name, tool_input, tool_response }` | ✅ jq で解析 |
| **処理** | .claude/logs/subagent-dispatch.log に記録 | ✅ JSONL 形式 |
| **exit code** | 0 (常に通過) | ✅ 情報収集のみ |
| **実装根拠** | project.md phase_completion_output「ログの構造的記録」 | SubAgent 実行の追跡可能性 |

#### 1.6.2 archive-playbook.sh

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **仕様セクション** | 1.1 PostToolUse, 6.2 検証パターン | ✅ 準拠 |
| **matcher** | Edit | ✅ settings.json L180 |
| **処理** | playbook 編集時、全 Phase が done かチェック | ✅ アーカイブ提案出力 |
| **exit code** | 0 (常に通過) | ✅ ブロックなし |
| **実装根拠** | project.md playbook_doubt_ability「archive_reference」 | 完了 playbook の整理 |

### 1.7 Stop Hook

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **ファイル** | - | stop-summary.sh |
| **仕様セクション** | 1.1 Stop, 6.3 継続判定パターン | ✅ 準拠 |
| **発火タイミング** | メインエージェント停止試行時 | ✅ Stop(*) |
| **入力 (stdin)** | `{ stop_hook_active: true }` | ✅ 使用せず（state.md 直接参照） |
| **出力** | JSON (decision, reason) または stdout | ✅ ASCIIart サマリー |
| **exit code** | 0 (ブロックなし) | ✅ 情報提供のみ |
| **実装根拠** | project.md phase_completion_output「Phase 完了サマリー」 | LLM 依存しない状態出力 |

### 1.8 SessionEnd Hook

| 項目 | 公式仕様 | 現在実装 |
|------|---------|---------|
| **ファイル** | - | session-end.sh |
| **仕様セクション** | 1.1 SessionEnd | ✅ 準拠 |
| **発火タイミング** | セッション終了時 | ✅ SessionEnd(*) |
| **処理** | state.md 更新、未 push 警告、クリーンアップ | ✅ 準拠 |
| **exit code** | 0 (常に通過) | ✅ ブロックなし |
| **実装根拠** | 1.7「SessionEnd → [クリーンアップ]」 | セッション状態の永続化 |

### 1.9 未登録・未実装 Hook（6個）

| Hook | 公式仕様セクション | 現在状態 | 理由 |
|------|------------------|---------|------|
| check-state-update.sh | 1.1 PreToolUse | 間接呼出 | pre-bash-check.sh から呼び出し |
| check-manifest-sync.sh | - | 手動用 | 定期実行ではなく手動確認用 |
| check-playbook-quality.sh | - | 手動用 | playbook 作成時の品質チェック |
| SubagentStop Hook | 1.1 SubagentStop | 未実装 | PostToolUse(Task) + log-subagent.sh で代替 |
| PreCompact Hook | 1.1 PreCompact | 未実装 | 優先度低（context-management Skill で代替可能） |
| Notification Hook | 1.1 Notification | 未実装 | 優先度低（通知機能不要） |

---

## 2. SubAgents 完全対応表（9個）

### 2.1 公式仕様 vs 現在実装

| SubAgent | 仕様セクション | description キーワード | tools | model | 状態 |
|----------|---------------|----------------------|-------|-------|------|
| critic | 2.1, 2.2 | MUST BE USED | Read, Grep, Bash | haiku | ✅ |
| pm | 2.1, 2.2 | PROACTIVELY | Read, Write, Edit, Grep, Glob | haiku | ✅ |
| coherence | 2.1, 2.2 | PROACTIVELY | Read, Bash, Grep | haiku | ✅ |
| state-mgr | 2.1, 2.2 | AUTOMATICALLY | Read, Edit, Write, Grep, Bash | haiku | ✅ |
| reviewer | 2.1 | (なし) | Read, Grep, Glob, Bash | haiku | ⚠️ 手動のみ |
| health-checker | 2.1 | (日本語) | Read, Grep, Glob, Bash | haiku | ⚠️ 日本語 |
| plan-guard | 2.1, 2.2 | PROACTIVELY | Read, Grep, Glob | haiku | ✅ |
| setup-guide | 2.1, 2.2 | AUTOMATICALLY | Read, Write, Edit, Bash, Grep, Glob | sonnet | ✅ |
| beginner-advisor | 2.1, 2.2 | AUTOMATICALLY | Read | haiku | ✅ |

### 2.2 実装根拠詳細

#### 2.2.1 critic

```yaml
公式仕様: 2.2 発火トリガー「自動委譲: description に『AUTOMATICALLY』を含める」
実装: description に「MUST BE USED before marking any task as done」
根拠: project.md tdd_and_fraud_prevention Layer 2「critic SubAgent」
連携: critic-guard.sh が exit 2 → LLM が critic を呼び出し
```

#### 2.2.2 pm

```yaml
公式仕様: 2.2 発火トリガー「自動委譲: description に『PROACTIVELY』を含める」
実装: description に「PROACTIVELY manages playbooks」
根拠: CLAUDE.md POST_LOOP「pm を呼び出して playbook 作成」
連携: playbook-guard.sh が exit 2 → LLM が pm を呼び出し
```

#### 2.2.3 coherence

```yaml
公式仕様: 2.2 発火トリガー
実装: description に「PROACTIVELY checks state.md and playbook consistency」
根拠: project.md project_playbook_sync「check-coherence.sh」
連携: check-coherence.sh の警告 → LLM が coherence を呼び出し
```

#### 2.2.4 state-mgr

```yaml
公式仕様: 2.2 発火トリガー
実装: description に「AUTOMATICALLY manages state.md」
根拠: state.md が Single Source of Truth → 専門 SubAgent で管理
連携: state.md 操作時に LLM が自動委譲
```

#### 2.2.5 reviewer

```yaml
公式仕様: 2.1 定義形式
実装: description に自動委譲キーワードなし
根拠: コードレビューは明示的な指示が必要
改善案: 「AUTOMATICALLY reviews code」を追加
```

#### 2.2.6 health-checker

```yaml
公式仕様: 2.1 定義形式
実装: description が日本語のみ
根拠: 定期監視は明示的な指示が必要
改善案: 英語 description を追加（「PROACTIVELY monitors system state」）
```

#### 2.2.7 plan-guard

```yaml
公式仕様: 2.2 発火トリガー
実装: description に「PROACTIVELY checks 3-layer plan coherence」
根拠: project.md plan_hierarchy「Macro → Medium → Micro」
連携: セッション開始時に LLM が自動委譲
```

#### 2.2.8 setup-guide

```yaml
公式仕様: 2.2 発火トリガー、2.3 ビルトイン SubAgent（model 指定）
実装: model: sonnet, description に「AUTOMATICALLY guides setup process」
根拠: setup レイヤーは複雑 → Sonnet モデルが必要
連携: focus=setup 時に LLM が自動委譲
```

#### 2.2.9 beginner-advisor

```yaml
公式仕様: 2.2 発火トリガー
実装: description に「AUTOMATICALLY explains technical terms」
根拠: 初心者向け説明は自動的に行うべき
連携: 初心者質問検出時に LLM が自動委譲
```

---

## 3. Skills 完全対応表（9個）

### 3.1 公式仕様 vs 現在実装

| Skill | 仕様セクション | ファイル名 | frontmatter | 状態 |
|-------|---------------|-----------|-------------|------|
| state | 3.1 | SKILL.md | ✅ | ✅ 正常 |
| plan-management | 3.1 | SKILL.md | ✅ | ✅ 正常 |
| context-management | 3.1, 3.3 | SKILL.md | ✅ + triggers | ✅ 正常 |
| execution-management | 3.1, 3.3 | SKILL.md | ✅ + triggers | ✅ 正常 |
| learning | 3.1, 3.3 | SKILL.md | ✅ + triggers | ✅ 正常 |
| frontend-design | 3.1 | SKILL.md | ❌ | ⚠️ frontmatter 不完全 |
| lint-checker | 3.1 | skill.md | ❌ | ⚠️ ファイル名 + frontmatter |
| test-runner | 3.1 | skill.md | ❌ | ⚠️ ファイル名 + frontmatter |
| deploy-checker | 3.1 | skill.md | ❌ | ⚠️ ファイル名 + frontmatter |

### 3.2 実装根拠詳細

#### 3.2.1 state

```yaml
公式仕様: 3.1 定義形式
実装: name: state, description: 「state.md 管理、playbook 運用、レイヤー構造の専門知識」
根拠: state.md が Single Source of Truth
参照タイミング: state.md 操作時
```

#### 3.2.2 plan-management

```yaml
公式仕様: 3.1, 3.3 発火トリガー
実装: name: plan-management, description に triggers キーワード（plan, playbook, phase, roadmap, milestone）
根拠: project.md plan_hierarchy「3層計画構造」
参照タイミング: 計画関連キーワード検出時
```

#### 3.2.3 context-management

```yaml
公式仕様: 3.1, 3.3 発火トリガー
実装: triggers: [/compact 前, 80% 超過時, セッション終了時]
根拠: CLAUDE.md CONTEXT「コンテキスト管理」
参照タイミング: /compact 実行前、コンテキスト逼迫時
```

#### 3.2.4 execution-management

```yaml
公式仕様: 3.1, 3.3 発火トリガー
実装: triggers: [複数タスク同時実行時, コンテキスト逼迫時]
根拠: 並列実行制御の最適化
参照タイミング: 並列タスク開始時
```

#### 3.2.5 learning

```yaml
公式仕様: 3.1, 3.3 発火トリガー
実装: triggers: [エラー発生時, critic FAIL 時]
根拠: project.md learning_skill_design「失敗パターン自動学習」
参照タイミング: エラー/FAIL 発生時
```

#### 3.2.6-9 frontmatter 不完全な Skill

```yaml
問題: frontend-design, lint-checker, test-runner, deploy-checker
公式仕様: 3.1「SKILL.md に YAML frontmatter 必須」
現在: frontmatter なし、または ファイル名が skill.md
影響: Claude が自動発見しにくい
対策: Phase 7 で修正
```

---

## 4. Commands 完全対応表（7個）

| Command | 仕様セクション | ファイル | 説明 | 関連 SubAgent |
|---------|---------------|---------|------|--------------|
| /crit | 4.1 | crit.md | done_criteria チェック | critic |
| /playbook-init | 4.1 | playbook-init.md | 新タスク開始フロー | pm |
| /lint | 4.1 | lint.md | 整合性チェック | coherence |
| /focus | 4.1 | focus.md | レイヤーフォーカス切替 | state-mgr |
| /test | 4.1 | test.md | done_criteria テスト | - |
| /rollback | 4.1 | rollback.md | Git ロールバック | - |
| /state-rollback | 4.1 | state-rollback.md | state.md 復元 | - |

### 4.1 公式仕様準拠確認

```yaml
公式仕様 4.1:
  - ファイル: .claude/commands/command-name.md
  - frontmatter: description (必須), allowed-tools, model, argument-hint (任意)
  - パラメータ: $ARGUMENTS, $1, $2, ...

現在実装:
  - 全 7 Command が .claude/commands/ に存在
  - frontmatter: description 記載済み
  - 状態: ✅ 公式仕様準拠
```

---

## 5. 公式仕様未使用機能

| 機能 | 公式仕様セクション | 状態 | 理由 |
|------|------------------|------|------|
| validation Hook タイプ | 1.2 | 未使用 | command タイプで十分 |
| notification Hook タイプ | 1.2 | 未使用 | 通知機能不要 |
| CLAUDE_ENV_FILE | 1.5 | 未使用 | 環境変数永続化不要 |
| permissionDecision | 1.6 | 未使用 | exit 2 でブロックするため |
| updatedInput | 1.6 | 未使用 | パラメータ変更不要 |
| SubagentStop Hook | 1.1 | 未使用 | PostToolUse(Task) で代替 |
| PreCompact Hook | 1.1 | 未使用 | context-management Skill で代替 |
| Notification Hook | 1.1 | 未使用 | 通知機能不要 |
| PermissionRequest Hook | 1.1 | 未使用 | bypassPermissions モードのため |
| SubAgent skills フィールド | 2.1 | 未使用 | 手動でスキル参照 |
| SubAgent capabilities | 2.1 | 未使用 | プラグイン用（未使用） |

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-09 | Phase 4 完了。Hooks 15+6 個、SubAgents 9 個、Skills 9 個、Commands 7 個の公式仕様対応を明記。 |

---

**作成日時**: 2025-12-09
**作成者**: Claude Code（P4 実行）
**状態**: ✅ 完了、Phase 5 へ移行可能
