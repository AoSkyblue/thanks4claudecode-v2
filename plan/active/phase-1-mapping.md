# Phase 1 成果物: 公式仕様マッピング

> **playbook-current-implementation-redesign Phase 1 完了**
>
> 日時: 2025-12-09
> 目的: extension-system.md の完全理解と現在実装との対応関係を確立

---

## 概要

extension-system.md の全 6 セクションをカテゴリ別に整理し、各セクションの仕様要件と現在の実装の対応状況を分析しました。

---

## Section 1: Hooks（イベント駆動型）

### 1.1 公式仕様: 利用可能な Hook イベント（10種類）

| No | イベント名 | 発火タイミング | matcher | 用途 | 備考 |
|-----|-----------|-----------|--------|------|------|
| 1 | PreToolUse | ツール実行前（パラメータ作成後） | ✓ | 権限制御、パラメータ変更、ブロック | **最重要** |
| 2 | PostToolUse | ツール実行成功後 | ✓ | 結果検証、追加コンテキスト注入 | |
| 3 | PermissionRequest | 権限ダイアログ表示時 | ✓ | 権限判定のカスタマイズ | 未使用 |
| 4 | **UserPromptSubmit** | ユーザープロンプト送信時 | - | 入力検証、コンテキスト追加 | **新規実装済み** |
| 5 | **Stop** | メインエージェント停止試行時 | - | 継続判定、追加タスク指示 | **新規実装済み** |
| 6 | SubagentStop | サブエージェント停止試行時 | - | サブタスク評価、継続判定 | ⚠️ 代替実装 |
| 7 | SessionStart | セッション開始/再開時 | - | 環境初期化、変数設定 | ✅ 実装済み |
| 8 | SessionEnd | セッション終了時 | - | クリーンアップ、ログ記録 | ✅ 実装済み |
| 9 | PreCompact | コンテキスト圧縮前 | - | 重要情報の保持指示 | 未使用（低優先度） |
| 10 | Notification | 通知送信時 | - | 通知カスタマイズ | 未使用（低優先度） |

**現在実装状況**: 10/10 中 8 つが概念的に対応、2 つ（PreCompact, Notification）は未使用

### 1.2 公式仕様: Hook タイプ（3種類）

| タイプ | 説明 | 現在実装での使用 |
|--------|------|-----------------|
| **command** | シェルコマンドまたはスクリプト実行 | ✅ 全 18 Hook で使用 |
| validation | ファイルコンテンツまたはプロジェクト状態検証 | ⚠️ 未使用（事実上 command で検証） |
| notification | アラート、ステータス更新送信 | 未使用 |

**現在実装**: command 型のみ。validation/notification は未活用。

### 1.3 公式仕様: matcher の仕様

| パターン | 説明 | settings.json での使用例 |
|---------|------|--------------------------|
| 完全一致 | "Write" | ✅ 多数使用 |
| 正規表現 | "Edit\|Write" | ✅ 使用 |
| ワイルドカード | "*" または "" | ✅ 使用（PreToolUse:*） |
| MCP | "mcp__server__tool" | 未使用 |

**現在実装**: 正規表現とワイルドカード組み合わせで柔軟に対応。

### 1.4 公式仕様: 入力データ（stdin JSON）

#### 共通フィールド
```json
{
  "session_id": "string",
  "transcript_path": "string",
  "cwd": "string",
  "permission_mode": "default|plan|acceptEdits|bypassPermissions",
  "hook_event_name": "string"
}
```

#### イベント固有フィールド
| イベント | 固有フィールド | 現在実装での対応 |
|---------|--------------|-----------------|
| PreToolUse | tool_name, tool_input, tool_use_id | ✅ jq で抽出 |
| PostToolUse | tool_name, tool_input, tool_response | ✅ 一部使用 |
| UserPromptSubmit | prompt | ✅ 新規実装 |
| Stop/SubagentStop | stop_hook_active | 一部確認 |
| SessionStart | source (startup\|resume\|clear\|compact) | ✅ 確認 |

**現在実装**: stdin JSON を主に jq で抽出。完全スキーマ検証はなし。

### 1.5 公式仕様: 環境変数

| 変数 | 説明 | 利用可能時 | 現在実装での対応 |
|-----|------|----------|-----------------|
| `CLAUDE_PROJECT_DIR` | プロジェクトルート絶対パス | 全 Hook | ✅ 使用 |
| `CLAUDE_CODE_REMOTE` | リモート環境フラグ（"true"） | 全 Hook | ⚠️ 確認未 |
| `CLAUDE_ENV_FILE` | 環境変数永続化ファイル | SessionStart のみ | ⚠️ 未使用 |
| `${CLAUDE_PLUGIN_ROOT}` | プラグインディレクトリ絶対パス | プラグイン内 Hook | N/A |

**現在実装**: CLAUDE_PROJECT_DIR は活用。CLAUDE_ENV_FILE は未活用（環境変数永続化不要の設計）。

### 1.6 公式仕様: 出力と効果

#### 終了コード
| コード | 意味 | 現在実装での対応 |
|-------|------|-----------------|
| 0 | 成功 | ✅ 標準 |
| 2 | ブロック | ✅ ブロック時に明示的に exit 2 |
| その他 | 警告表示、実行継続 | ⚠️ 警告パターン少ない |

#### JSON 出力（終了コード 0 時のみ処理）

```json
{
  "continue": false,           // Claude 停止
  "stopReason": "string",      // 停止理由
  "systemMessage": "string",   // ユーザー向け警告

  "hookSpecificOutput": {
    // PreToolUse 専用
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "string",
    "updatedInput": {},

    // PostToolUse 専用
    "additionalContext": "string"
  },

  "decision": "block",  // UserPromptSubmit/Stop 専用
  "reason": "string"
}
```

**現在実装**:
- exit code は厳密に 0/2 を使用
- JSON 出力は未使用（stdout テキスト出力が主）
- systemMessage は使用していない（プロンプト内埋め込み）

### 1.7 公式仕様: 連携パターン

```
SessionStart → [環境初期化]
     ↓
UserPromptSubmit → [入力検証]
     ↓
PreToolUse → [権限/パラメータ制御]
     ↓
[ツール実行]
     ↓
PostToolUse → [結果検証/コンテキスト追加]
     ↓
Stop/SubagentStop → [継続判定]
     ↓
SessionEnd → [クリーンアップ]
```

**現在実装**: この連携はほぼ実装されているが、Stop での継続判定が完全ではない。

---

## Section 2: SubAgents（委譲型）

### 2.1 公式仕様: 定義形式

```yaml
# .claude/agents/agent-name.md

---
name: agent-identifier        # 必須: 小文字・ハイフン
description: 機能と使用時機    # 必須: 自動委譲のトリガー
tools: Read, Grep, Glob       # 任意: 省略で全ツール継承
model: sonnet                 # 任意: sonnet|opus|haiku|inherit
permissionMode: default       # 任意: default|acceptEdits|bypassPermissions|plan|ignore
skills: skill1, skill2        # 任意: 自動ロードするスキル
capabilities:                 # 任意: 得意なタスクのリスト（プラグイン用）
  - task1
  - task2
---

システムプロンプト（詳細な指示）
```

**現在実装**: frontmatter は完全に実装。capabilities は未使用。

### 2.2 公式仕様: 発火トリガー

| トリガー | 説明 | 現在実装での対応 |
|---------|------|-----------------|
| 自動委譲 | description に「PROACTIVELY」「AUTOMATICALLY」 | ✅ 9 つ中 6 つが対応 |
| 手動呼び出し | ユーザー指示または Task ツール | ✅ /crit, /playbook-init など |
| CLI | --agents パラメータ | N/A |

**現在実装**: 自動委譲と手動呼び出しが混在。reviewer/health-checker の自動委譲は弱い。

### 2.3 現在実装: SubAgents 一覧（9個）

| No | Agent 名 | model | 自動委譲 | 用途 |
|-----|---------|-------|--------|------|
| 1 | critic | haiku | ✅ MUST BE USED | done_criteria 検証 |
| 2 | pm | haiku | ✅ PROACTIVELY | playbook 管理、スコープ |
| 3 | coherence | haiku | ✅ PROACTIVELY | 整合性チェック |
| 4 | state-mgr | haiku | ✅ AUTOMATICALLY | state.md 操作 |
| 5 | reviewer | haiku | ⚠️ なし | コードレビュー |
| 6 | health-checker | haiku | ⚠️ なし（日本語） | 状態監視 |
| 7 | plan-guard | haiku | ✅ PROACTIVELY | plan 整合性 |
| 8 | setup-guide | sonnet | ✅ AUTOMATICALLY | setup ガイド |
| 9 | beginner-advisor | haiku | ✅ AUTOMATICALLY | 初心者説明 |

**公式仕様との対応**: 9/9 個が frontmatter 対応済み。reviewer/health-checker の自動委譲を改善。

---

## Section 3: Skills（自動発見型）

### 3.1 公式仕様: 定義形式

```yaml
# .claude/skills/skill-name/SKILL.md

---
name: skill-identifier        # 必須: 小文字・数字・ハイフン（最大64文字）
description: 機能と使用時機    # 必須: 自動発見のキー（最大1024文字）
---

スキルの詳細説明と指示
```

### 3.2 補足ファイル（オプション）

```
.claude/skills/skill-name/
├── SKILL.md           # 必須
├── reference.md       # 任意
├── examples.md        # 任意
├── scripts/           # 任意
└── templates/         # 任意
```

### 3.3 公式仕様: 発火トリガー

- **モデル呼び出し（Model-Invoked）**: ユーザーリクエストと description を照合
- **自動判断**: リクエスト内容、Skill description、コンテキストで判定

### 3.4 現在実装: Skills 一覧（9個）

| No | Skill 名 | ファイル | frontmatter | 状態 |
|-----|----------|---------|-----------|------|
| 1 | state | SKILL.md | ✅ | ✅ 正常 |
| 2 | plan-management | SKILL.md | ✅ | ✅ 正常 |
| 3 | context-management | SKILL.md | ✅ + triggers | ✅ 正常 |
| 4 | execution-management | SKILL.md | ✅ + triggers | ✅ 正常 |
| 5 | learning | SKILL.md | ✅ + triggers | ✅ 正常 |
| 6 | frontend-design | SKILL.md | ❌ | ⚠️ frontmatter 未記載 |
| 7 | lint-checker | skill.md | ❌ | ⚠️ ファイル名+frontmatter |
| 8 | test-runner | skill.md | ❌ | ⚠️ ファイル名+frontmatter |
| 9 | deploy-checker | skill.md | ❌ | ⚠️ ファイル名+frontmatter |

**問題点**:
- frontend-design, lint-checker, test-runner, deploy-checker が frontmatter 未記載
- lint-checker, test-runner, deploy-checker がファイル名 skill.md（小文字）→ SKILL.md 推奨

### 3.5 triggers フィールド（拡張仕様）

| Skill | triggers 定義 | 説明 |
|------|------------|------|
| context-management | /compact 前、80% 超過、セッション終了 | ✅ 定義済み |
| execution-management | 複数タスク同時、コンテキスト逼迫 | ✅ 定義済み |
| learning | エラー発生、critic FAIL | ✅ 定義済み |

**現在実装**: triggers はガイドライン。実装は triggers に基づく自動参照なし（手動呼び出し依存）。

---

## Section 4: Slash Commands（明示呼出型）

### 4.1 公式仕様: 定義形式

```yaml
# .claude/commands/command-name.md

---
description: コマンドの説明
allowed-tools: Bash(git:*), Read  # 任意
model: sonnet                     # 任意
argument-hint: <issue-number>     # 任意
---

プロンプトテンプレート
$ARGUMENTS, $1, $2 などで引数受け取り
```

### 4.2 現在実装: Commands 一覧（7個）

| No | Command | ファイル | 関連 Agent | 用途 |
|-----|---------|---------|-----------|------|
| 1 | /crit | crit.md | critic | done_criteria チェック |
| 2 | /playbook-init | playbook-init.md | pm | 新タスク開始 |
| 3 | /lint | lint.md | coherence | 整合性チェック |
| 4 | /focus | focus.md | state-mgr | レイヤーフォーカス切替 |
| 5 | /test | test.md | - | done_criteria テスト |
| 6 | /rollback | rollback.md | - | Git ロールバック |
| 7 | /state-rollback | state-rollback.md | - | state.md 復元 |

**現在実装**: frontmatter は確認未。$ARGUMENTS パラメータの使用可否も未確認。

---

## Section 5: 連携マトリクス

### 5.1 Hook → SubAgent 連携

| Hook | SubAgent | 呼び出し方式 | 実装状況 |
|------|---------|-----------|--------|
| playbook-guard.sh | pm | systemMessage 推奨 | ⚠️ exit 2 でブロック |
| critic-guard.sh | critic | CLAUDE.md LOOP 強制 | ✅ 行動ルール |
| check-coherence.sh | coherence | 手動または commit 時 | ✅ 間接呼出 |

**現在実装**: Hook → SubAgent の連携は事実上、CLAUDE.md の行動ルール（読み込みに依存）。JSON 出力での systemMessage 指示なし。

### 5.2 Hook → Skill 連携

| Hook | Skill | トリガー | 実装状況 |
|------|------|---------|--------|
| session-start.sh | state | セッション開始時 | ⚠️ ガイドライン依存 |
| pre-bash-check.sh | learning | 失敗時 | ⚠️ 手動参照 |

**現在実装**: Skill 参照は LLM の自動判断に依存。構造的トリガーなし。

### 5.3 SubAgent → Skill 連携

| SubAgent | skills フィールド | 実装状況 |
|---------|-----------------|--------|
| pm | 未指定 | ⚠️ 設定なし |
| critic | 未指定 | ⚠️ 設定なし |
| setup-guide | 未指定 | ⚠️ 設定なし |

**現在実装**: SubAgent の frontmatter に skills フィールドなし。

---

## Section 6: 設計パターン

### 6.1 ガードパターン（PreToolUse）

**公式パターン**:
```bash
if [[ 条件 ]]; then
  echo "理由" >&2
  exit 2  # ブロック
fi
exit 0  # 許可
```

**現在実装**:
- ✅ init-guard.sh, playbook-guard.sh, critic-guard.sh などで標準的に実装
- ✅ exit 2 でブロック、exit 0 で許可を厳密に使用

### 6.2 検証パターン（PostToolUse）

**公式パターン**: 結果検証 → JSON 出力

**現在実装**:
- ⚠️ log-subagent.sh は stdout テキスト出力（JSON なし）
- ❌ additionalContext への JSON 出力なし

### 6.3 継続判定パターン（Stop）

**公式パターン**: 未完了条件 → decision: block

**現在実装**:
- ✅ stop-summary.sh 実装（新規）
- ⚠️ decision: block の JSON 出力確認未

### 6.4 環境初期化パターン（SessionStart）

**公式パターン**: CLAUDE_ENV_FILE に環境変数書き込み

**現在実装**:
- ⚠️ session-start.sh は pending ファイル作成（環境変数永続化不要の設計）
- ❌ CLAUDE_ENV_FILE 活用なし

---

## マッピングサマリー

### 実装率（概念的対応）

| カテゴリ | 対応数 | 全数 | 実装率 |
|---------|-------|------|--------|
| Hooks イベント | 8 | 10 | 80% |
| Hook タイプ | 1 | 3 | 33% |
| Hooks 出力形式 | ⚠️ 部分的 | 完全 | - |
| SubAgents | 9 | 9 | 100% |
| SubAgent 発火 | 6 | 9 | 67% |
| Skills | 5/9 | 9 | 56% |
| Skills frontmatter | 5 | 9 | 56% |
| Commands | 7 | 7 | 100% |
| 連携パターン | 2/4 | 4 | 50% |

### 改善が必要な項目（優先度順）

#### P0: 構造的に必要

1. **SubAgent 発火の自動委譲強化**
   - reviewer, health-checker の description 改善
   - 複数 SubAgent の連携強化

2. **Skills frontmatter 完成**
   - frontend-design, lint-checker, test-runner, deploy-checker に YAML frontmatter 追加
   - lint-checker/test-runner/deploy-checker をファイル名 SKILL.md に統一

#### P1: 公式仕様準拠

3. **Hook JSON 出力の完全化**
   - hookSpecificOutput での additionalContext 出力
   - systemMessage での警告表示（stdout 代わり）

4. **SubAgent → Skill 連携**
   - SubAgent frontmatter に skills フィールド追加

5. **CLAUDE_ENV_FILE の活用**
   - 環境変数永続化を検討

#### P2: オプション

6. PreCompact, Notification Hook（未使用）
7. validation, notification Hook タイプ（未使用）

---

## 結論

**現在実装の評価**:
- コア機能（Hooks のガードパターン、SubAgent 定義、Command）は公式仕様に対応
- 連携（Hook → SubAgent/Skill）は事実上、CLAUDE.md の行動ルールに依存
- JSON 出力、Hook タイプの多様化は未活用

**次の Phase で対応**:
- Phase 2 で完全な棚卸し（実装コード確認）
- Phase 3, 4 で仕様ズレの詳細化
- Phase 8 で最終的な実装ガイドラインを提示

---

## 参照リンク

- **公式仕様**: docs/extension-system.md
- **現在実装**: plan/active/playbook-current-implementation-redesign.md（本 playbook）
- **次フェーズ**: Phase 2 - 完全な棚卸し

---

**作成日時**: 2025-12-09
**作成者**: Claude Code（P1 実行）
**状態**: ✅ 完了、Phase 2 へ移行可能
