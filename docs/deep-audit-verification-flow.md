# Deep Audit: 検証動線（Verification Flow）

> **M151: 検証動線の全5ファイルを精査し、凍結判定を実施**
>
> 実施日: 2025-12-21

---

## 概要

検証動線は「/crit → critic → PASS/FAIL」のフローを構成するコンポーネント群。
phase 完了前の品質保証と自己報酬詐欺防止を担う。

---

## 精査結果サマリー

| # | ファイル | 行数 | 役割 | 処遇 | 理由 |
|---|----------|------|------|------|------|
| 1 | crit.md | 36 | /crit コマンド | **Keep (Core)** | 検証動線のエントリーポイント |
| 2 | critic.md | 263 | 批判的評価エージェント | **Keep (Core)** | 証拠ベース判定の中核 |
| 3 | critic-guard.sh | 120 | 完了ブロック Guard | **Keep (Core)** | 構造的詐欺防止 |
| 4 | test.md | 36 | /test コマンド | **Simplify** | 機能が限定的 |
| 5 | lint.md | 25 | /lint コマンド | **Keep** | コミット前検証 |

---

## 詳細分析

### 1. crit.md - Keep (Core)

**パス**: `.claude/commands/crit.md`

**役割**:
- /crit コマンドとして done_criteria の達成状況をチェック
- state.md から done_criteria を取得し、各項目を評価

**出力形式**:
```
[CRITIQUE]
done_criteria 達成状況:
  - {criteria1}: {PASS|FAIL} - {証拠}
  - {criteria2}: {PASS|FAIL} - {証拠}
判定: {PASS|FAIL}
```

**主要ルール**:
- 「満たしている気がする」ではなく具体的な証拠を示す
- 1つでも FAIL なら全体が FAIL

**凍結理由**:
- 検証動線の起点
- ユーザーが明示的に検証を要求するインターフェース
- これがなければ critic を呼び出す標準的な方法がない

---

### 2. critic.md - Keep (Core)

**パス**: `.claude/agents/critic.md`

**役割**:
- Critique Evaluator Agent
- done_criteria の厳密な評価と自己報酬詐欺防止

**主要機能**:
```yaml
証拠ベースの判定:
  - ファイル存在: ls -la で確認
  - 機能動作: 実行結果を引用
  - 条件充足: 該当箇所を引用
  - テスト結果: exit code、出力

批判的思考の原則:
  - 「完了した」と思った瞬間が最も危険
  - 自分の成果物を敵対的に評価する
  - ユーザーが「これ違う」と言う前に自分で気づく

V11 subtasks 検証:
  - 各 subtask の test_command を実行
  - PASS/FAIL を判定
  - 1つでも FAIL なら phase を FAIL

Skills 連携:
  - lint-checker: 静的解析エラーチェック
  - test-runner: テスト実行
  - deploy-checker: デプロイ状態確認
```

**出力形式（V11）**:
```
[CRITIQUE]

subtasks 達成状況:
  - p{N}.1: {PASS|FAIL|DEFERRED}
    criterion: "{criterion の内容}"
    test_command: "{実行したコマンド}"
    証拠: {具体的な証拠}

subtask サマリー:
  PASS: {N}個
  FAIL: {N}個
  DEFERRED: {N}個

総合判定: {PASS|FAIL}
```

**凍結理由**:
- 検証動線の中核エージェント
- 証拠ベース判定の標準を定義
- 自己報酬詐欺防止の構造的保証
- V11 subtasks 検証ロジックを実装

---

### 3. critic-guard.sh - Keep (Core)

**パス**: `.claude/hooks/critic-guard.sh`

**役割**:
- PreToolUse(Edit) Hook
- critic PASS なしで phase/state を完了にすることを防止

**主要機能**:
```yaml
対象ファイル判定:
  - state.md: IS_STATE_MD=true
  - playbook-*.md: IS_PLAYBOOK=true

完了パターン検出:
  - state: done
  - status: done または completed

ブロック条件:
  - self_complete: true が state.md に存在しない
  - 完了パターンへの変更を検出

ブロック時の出力:
  - critic 未実行の警告
  - 対処法の説明
  - 「証拠なしの done は自己報酬詐欺」
```

**凍結理由**:
- 構造的な詐欺防止メカニズム
- これがなければ critic を経由せずに完了にできてしまう
- CLAUDE.md の Core Contract を実装

---

### 4. test.md - Simplify

**パス**: `.claude/commands/test.md`

**役割**:
- /test コマンドとして done_criteria テストを実行
- test-done-criteria.sh のラッパー

**内容分析**:
```yaml
現状:
  - test-done-criteria.sh を呼び出すだけ
  - 36行と簡素
  - /crit と機能が重複

問題点:
  - /crit が同じ目的を達成
  - test-done-criteria.sh 自体が古い設計
  - V11 subtasks では test_command で直接検証

簡素化提案:
  - /crit への統合を検討
  - または test-done-criteria.sh の削除と共に廃止
  - 現状は残すが、将来的に整理対象
```

---

### 5. lint.md - Keep

**パス**: `.claude/commands/lint.md`

**役割**:
- /lint コマンドとして整合性チェックを実行
- check-coherence.sh のラッパー

**チェック項目**:
- state.md と playbook の整合性
- focus.current の有効性
- staged ファイルと focus の矛盾検出

**凍結理由**:
- コミット前の必須検証
- 四つ組整合性の確認手段
- シンプルで明確な役割

---

## テスト結果

```
Flow Runtime Test Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PASS: 33
  FAIL: 0

  ALL FLOW RUNTIME TESTS PASSED
```

検証動線関連テスト（V1-V5）: 全て PASS

---

## Codex レビュー結果

```yaml
レビュー日: 2025-12-21
レビュアー: Codex

全体評価: Approved

コメント:
  - critic.md: V11 subtasks 検証は良い設計。Skills 連携も明確。
  - critic-guard.sh: 構造的詐欺防止として適切。M106 改善も反映済み。
  - crit.md: シンプルで使いやすいインターフェース。

改善提案:
  - test.md: /crit との重複を解消すべき
  - critic.md と critic-guard.sh の連携を明文化すべき

結論: 検証動線は Core Layer として適切に設計されている。
```

---

## 結論

### Core として凍結するファイル（3ファイル）

1. **crit.md** - 検証動線のエントリーポイント
2. **critic.md** - 証拠ベース判定の中核
3. **critic-guard.sh** - 構造的詐欺防止

### Keep として維持するファイル（1ファイル）

4. **lint.md** - コミット前検証

### Simplify として簡素化するファイル（1ファイル）

5. **test.md** - /crit との統合を検討

---

## 検証動線の設計評価

```yaml
強み:
  - 三層構造（コマンド → エージェント → ガード）
  - 構造的に詐欺を防止（bypass 不可能）
  - V11 subtasks で test_command ベースの自動検証

改善点:
  - test.md と crit.md の役割整理
  - critic.md の行数が多い（263行）→ 分割検討

総合評価: 計画動線と並ぶ Core Layer として適切
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成 - M151 検証動線 Deep Audit |
